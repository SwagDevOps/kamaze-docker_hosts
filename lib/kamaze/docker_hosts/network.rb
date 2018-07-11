# frozen_string_literal: true

# Copyright (C) 2017-2018 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../docker_hosts'
autoload :Docker, 'docker'
autoload :IPAddr, 'ipaddr'
# @see https://github.com/excon/excon
autoload :Excon, 'excon'

# Describe current network as a Hash.
#
# Sample structure:
#
# ```
# {
#   "project_web" => [#<IPAddr: IPv4:172.17.0.2/255.255.255.255>],
#   "project_db" => [#<IPAddr: IPv4:172.17.0.3/255.255.255.255>]
# }
# ```
class Kamaze::DockerHosts::Network < Hash
  autoload :Configurator, "#{__dir__}/network/configurator"

  class << self
    # Configure a network from given config.
    #
    # @param [Kamaze::DockerHosts::Config|String|Pathname] config
    # @return [self]
    def configure(config)
      Configurator.new(config).network
    end
  end

  # Get extension used on hosts.
  #
  # @return [String|nil]
  attr_reader :extension

  def initialize
    reload!
  end

  # @return [String]
  def to_json
    autoload :JSON, 'json'

    JSON.public_send(empty? ? :generate : :pretty_generate, self.to_h)
  end

  # @return [String]
  def to_s
    maxl = self.keys.map(&:size).max.freeze
    self.to_a.map do |row|
      [
        "%<host>s%<padding>s\t" % {
          host: row[0],
          padding: "\s" * (maxl - row[0].size)
        },
        row[1]
      ]
    end.map { |row| row[0] + row[1].join("\s") }.join("\n")
  end

  # Denote network is available.
  #
  # When network is down, an exception is raised,
  # as a result, memento is set to ``nil``.
  #
  # @return [Boolean]
  def available?
    !self.memento.nil?
  end

  # Set extension.
  #
  # Extension is applied on records.
  #
  # @param [String] extension
  # @return [self]
  def extension=(extension)
    @extension = extension.to_s.empty? ? nil : extension.to_s

    clear.tap do
      memento.to_h.each do |host, ip|
        host = "#{host}.#{extension}" if extension

        self[host] = ip
      end
    end
  end

  # Reload itself.
  #
  # @return [self]
  def reload!
    begin
      @memento = self.class.hosts.sort.to_h
    rescue Excon::Error::Socket
      @memento = nil
    end

    self.reset
  end

  # Restore original state.
  #
  # @return [self]
  def reset
    self.tap do
      @extension = nil

      memento.to_h.each { |host, ip| self[host] = ip }
    end
  end

  protected

  # Get original state.
  #
  # @return [Hash|nil]
  attr_reader :memento

  class << self
    # Get containers.
    #
    # @raise [Excon::Error::Socket]
    # @return [Array<Docker::Container>]
    def containers
      Docker::Container.all
    end

    # Get hosts.
    #
    # @raise [Excon::Error::Socket]
    # @return [Hash]
    def hosts
      {}.tap do |rows|
        containers.each do |container|
          data = extract_hosts(container.info).to_h

          rows.merge!(data)
        end
      end
    end

    protected

    # Extract networks info (from given container info).
    #
    # @param [Hash] info
    # @return [Hash|nil]
    def extract_hosts(info) # rubocop:disable Metrics/MethodLength
      {}.tap do |rows|
        nets  = info['NetworkSettings']['Networks'].to_h
        names = info['Names'].to_a.map { |name| name.gsub(%r{^\/}, '') }

        names.each { |name| rows[name.to_s] = nil }
        nets.each do |_name, network|
          rows.each do |k, v|
            next unless network['IPAddress']

            rows[k] = rows[k].to_a.push(IPAddr.new(network['IPAddress']))
          end
        end
      end
    end
  end
end
