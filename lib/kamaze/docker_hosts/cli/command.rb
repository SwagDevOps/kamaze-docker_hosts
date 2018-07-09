# frozen_string_literal: true

require_relative '../cli'
require 'hanami/cli'

# @abstract
class Kamaze::DockerHosts::Cli::Command < Hanami::CLI::Command
  autoload :InterruptError, "#{__dir__}/command/interrupt_error"
  require_relative 'config'
  require_relative '../network'

  class << self
    protected

    # Enable network.
    #
    # @see #network()
    def enable_network
      Kamaze::DockerHosts::Network.new.tap do |network|
        @network = network

        self.singleton_class.define_method(:network) { network }
        # rubocop:disable Style/AccessModifierDeclarations
        self.singleton_class.class_eval { protected :network }
        # rubocop:enable Style/AccessModifierDeclarations
      end
    end

    # Set config option.
    #
    # @see #configure()
    def configurable
      option :config, \
             desc: 'Configuration directory',
             default: Kamaze::DockerHosts::Cli::Config.roots.last.to_s
    end

    # Denote current outputs are ``tty``.
    #
    # Possible values are: ``[both, stdout, stderr]``.
    #
    # @raise [ArgumentError]
    # @return [Boolean]
    def tty?(where = nil)
      res = {
        stderr: ($stderr.respond_to?(:tty?) and $stderr.tty?),
        stdout: ($stdout.respond_to?(:tty?) and $stdout.tty?),
      }.tap { |hsh| hsh.merge!(both: (hsh[:stdout] and hsh[:stderr])) }

      begin
        res.fetch((where || :both).to_sym)
      rescue KeyError
        raise ArgumentError, "#{where} not in #{res.keys.reverse}"
      end
    end
  end

  # Configure (from given options).
  #
  # Sample of use:
  #
  # ```ruby
  # class Hello < Command
  #   configurable
  #
  #   def call(**options)
  #     configure(options)
  #
  #     # access to config
  #     bar = config.foo.bar
  #   end
  # end
  # ```
  #
  # @param [Hash] options
  # @raise [KeyError]
  # @return [self]
  def configure(options)
    Kamaze::DockerHosts::Cli::Config.build do |c|
      c.add_root(options.fetch(:config))
    end.tap do |config|
      self.singleton_class.define_method(:_config) { config }
      # rubocop:disable Style/AccessModifierDeclarations
      self.singleton_class.class_eval { protected :_config }
      # rubocop:enable Style/AccessModifierDeclarations
    end

    self
  end

  protected

  # Interrupt command execution.
  #
  # @param [Symbol|Integer] status
  # @param [String] message
  #
  # @raise [Kamaze::DockerHosts::Cli::InterruptError]
  def halt(status, message = nil)
    InterruptError.new(message).tap do |err|
      err.status = status
      raise err
    end
  end

  # @see #configure
  # @return [Kamaze::DockerHosts::Cli::Config|nil]
  def config
    self._config.clone
  rescue NoMethodError
    nil
  end

  # @todo configure network from ``config``.
  # @return [Kamaze::DockerHosts::Network|nil]
  def network
    self.class.__send__(:network).clone
  rescue NoMethodError
    nil
  end

  # @return [Boolean]
  def tty?(*args)
    self.class.__send__(:tty?, args)
  end
end
