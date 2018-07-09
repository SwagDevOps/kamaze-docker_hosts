# frozen_string_literal: true

require_relative '../commands'
require_relative '../../file'

class Kamaze::DockerHosts::Cli
  # Display network status
  class Commands::Hosts < Command
    enable_network
    desc 'Display hosts'

    def call(**options)
      hosts = Kamaze::DockerHosts::File.new.update!(network)

      $stdout.puts(hosts)
    end

    protected

    # Prepare network rendering.
    #
    # @param [Kamaze::DockerHosts::Network] network
    # @return [Array]
    def prepare(network)
      network = network.to_a.map(&:flatten)
      max = network.map(&:size).max

      network.map { |row| row.push(*([nil] * (max - row.size))) }
    end

    def render(network, raw = false) # rubocop:disable Metrics/MethodLength
      return if network.empty?

      Terminal::Table.new do |table|
        table.rows = prepare(network)
        table.style = {
          border_top: false,
          border_bottom: false,
          border_y: '',
          padding_left: 0,
          padding_right: 4,
        }.public_send(raw ? :to_h : :clear)
      end
    end
  end
end
