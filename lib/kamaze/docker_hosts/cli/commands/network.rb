# frozen_string_literal: true

require_relative '../commands'
require 'terminal-table'

class Kamaze::DockerHosts::Cli
  # Display network status
  class Commands::Network < Command
    enable_network
    desc 'Display network status'
    # rubocop:disable Style/BracesAroundHashParameters
    option :raw, \
           {
             desc: 'Display raw values',
             type: :boolean,
             default: false
           }
    # rubocop:enable Style/BracesAroundHashParameters

    def call(**options)
      interrupt('Network unavailable.', :ENETDOWN) unless network.available?
      interrupt(nil, :NOERROR) if network.empty?

      $stdout.puts(render(network, options.fetch(:raw)))
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
