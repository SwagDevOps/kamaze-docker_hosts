# frozen_string_literal: true

# Copyright (C) 2017-2018 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../cli'
require 'sys/proc'
autoload :Docker, 'docker'
autoload :Tempfile, 'tempfile'
[
  'concern/configurable',
  'concern/log',
  'concern/signal',
  'concern/pipe',
  :configurator,
  :flock_error,
  :writer
].each { |req| require_relative "watcher/#{req}" }

# Watcher.
#
# Keep given (or configured) file updated across network changes.
#
# Sample of use:
#
# ```ruby
# network = Kamaze::DockerHosts::Network.new
# config = 'lib/kamaze/docker_hosts/configs'
# Kamaze::DockerHosts::Cli::Watcher.configure(config, network, 'hosts')
# ```
class Kamaze::DockerHosts::Cli::Watcher
  include Concern::Configurable
  include Concern::Pipe
  include Concern::Log
  include Concern::Signal

  # @return [Kamaze::DockerHosts::Network]
  attr_reader :network

  # @return [nil|Time]
  attr_reader :updated_at

  self.configurables = [:file, :logger, :ttl, :pidfile]

  # @return [Kamaze::DockerHosts::File]
  attr_accessor :file

  # @return [Integer]
  attr_accessor :ttl

  # @return [nil|Logger]
  attr_accessor :logger

  # @return [mil|Pathname]
  attr_accessor :pidfile

  class << self
    # Configure a watcher from given config.
    #
    # @return [self]
    def configure(*args)
      Configurator.new(*args).call
    end
  end

  # @param [Kamaze::DockerHosts::Network] network
  def initialize(network)
    yield(self) if block_given?
    setup
    attrs_lock!
    @network = network
    @writer = Writer.new(file.to_path, logger)
  end

  def watch
    { version: version, file: file.path, ttl: ttl }
      .map { |k, v| "#{k}: #{v}" }.join(', ')
      .tap { |s| log(s) }

    inner_watch
  end

  # @param [Hash{Symbol => Object}] options
  # @return [Integer|nil]
  def update(options = {}) # rubocop:disable Metrics/AbcSize
    mode = (options[:mode] || :updated).to_sym
    file.update!(network.reload!)
    return if file.hexdigest == file.hexdigest(true)

    writer.write(file.to_s).tap do |len|
      msg = "#{mode}: ##{network.keys.size}:#{len}(#{file.to_path.inspect})"
      msg = "#{msg}[#{options[:signal]}]" if options[:signal]
      log(msg)
    end
  end

  # Get pid from ``pidfile``.
  #
  # @return
  def fpid
    Pathname.new(pidfile).read.strip.to_i
  rescue Errno::ENOENT
    nil
  end

  # Creates a subprocess whith given block.
  #
  # @raise [FlockError]
  # @return [Integer]
  def fork(&block) # rubocop:disable Metrics/MethodLength
    pipe_init(:fork_error)
    Process.fork do
      suppress_output do
        begin
          lock(&block)
        rescue FlockError => e
          pipe_put(:fork_error, e)
        end
      end
    end.tap do |pid|
      pipe_get(:fork_error, 0.25)&.tap { |e| raise e }
      Process.detach(pid)
    end
  end

  # Lock given block with ``pidfile``.
  #
  # @return [self]
  def lock # rubocop:disable Metrics/MethodLength
    File.open(self.pidfile, File::RDWR | File::CREAT, 0o644) do |f|
      begin
        Timeout.timeout(0.1) { f.flock(File::LOCK_EX) }
      rescue Timeout::Error
        raise FlockError, "already running: #{fpid}"
      end

      f.write("#{Process.pid}\n")
      f.flush

      yield(self) if block_given?
    end

    self
  end

  protected

  attr_writer :updated_at

  # @return [Writer]
  attr_reader :writer

  def suppress_output
    streams = { $stdout => $stdout.clone, $stderr => $stderr.clone }
    streams.keys.each { |s| s.reopen(File.new(File::NULL, 'w')) }
    yield(self)
  ensure
    streams.each { |s, o| s.reopen(o) }
  end

  def inner_watch
    manage_signals
    loop do
      update.tap { |len| self.updated_at = Time.now if len }
      sleep(ttl)
    end
  end

  # @return [Kamaze::DockerHosts::VERSION]
  def version
    Kamaze::DockerHosts::VERSION
  end

  def setup
    if self.file.is_a?(String) or self.file.nil?
      @file = Kamaze::DockerHosts::File.new(self.file || '/etc/hosts')
    end

    @logger ||= syslog unless logger == false
    @pidfile ||= Tempfile.new(".#{Sys::Proc.progname}")
  end
end
