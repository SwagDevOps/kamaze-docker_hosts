# frozen_string_literal: true

require_relative '../commands'
require_relative '../../network'
require_relative '../../errno'
require 'terminal-table'

# Display network status
class Kamaze::DockerHosts::Cli::Commands::Network < Hanami::CLI::Command
  desc 'Display network status'
  option :raw, desc: 'Display raw values', \
               type: :boolean, default: false

  include Kamaze::DockerHosts::Errno

  def call(**options)
    network = self.network

    unless network.available?
      warn('Network unavailable.')
      return errno(:ENETDOWN) # 100
    end

    return if network.empty?
    $stdout.puts(render(network, options.fetch(:raw)))
  end

  protected

  # @return [Kamaze::DockerHosts::Network]
  def network
    Kamaze::DockerHosts::Network.new
  end

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
      if raw
        table.style = {
          border_top: false,
          border_bottom: false,
          border_y: '',
          padding_left: 0,
          padding_right: 4,
        }
      end
    end
  end
end
