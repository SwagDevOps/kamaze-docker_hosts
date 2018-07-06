# frozen_string_literal: true

# Copyright (C) 2017-2018 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../docker_hosts'

# Describe current network as a Hash.
#
# Sample structure:
#
# ```
# {
#   "project_web" => #<IPAddr: IPv4:172.17.0.2/255.255.255.255>,
#   "project_db" => #<IPAddr: IPv4:172.17.0.3/255.255.255.255>
# }
# ```
class Kamaze::DockerHosts::Network < Hash
  autoload :Docker, 'docker-api'
  autoload :IPAddr, 'ipaddr'
  # @see https://github.com/excon/excon
  autoload :Excon, 'excon'

  # @return [String|nil]
  attr_reader :extension

  def initialize
    @extension = nil
    begin
      @memento = self.class.hosts
    rescue Excon::Error::Socket
      @memento = nil
    end

    self.memento.to_h.each { |host, ip| self[host] = ip }
  end

  # Denotes memento has been populated.
  #
  # @return [Boolean]
  def memento?
    !self.memento.nil?
  end

  # Set extension.
  #
  # Extension is applied on records.
  #
  # @return [self]
  def extension=(extension)
    clear.tap do |hsh|
      memento.each do |host, ip|
        host = "#{host}.#{extension}" unless host.to_s.empty?

        hsh[host] = ip
      end

      @extension = extension
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
    def extract_hosts(info)
      {}.tap do |rows|
        nets  = info['NetworkSettings']['Networks'].to_h
        names = info['Names'].to_a.map { |name| name.gsub(%r{^\/}, '') }

        names.each { |name| rows[name.to_s] = nil }
        nets.each do |_name, network|
          rows.each do |k, v|
            rows[k] = IPAddr.new(network['IPAddress']) if network['IPAddress']
          end
        end
      end
    end
  end
end
