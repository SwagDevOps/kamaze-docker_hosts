# frozen_string_literal: true

require_relative '../cli'
require 'hanami/cli'
require_relative 'command'

class Kamaze::DockerHosts::Cli
  # CLI commands module
  module Commands
    extend Hanami::CLI::Registry

    autoload :Network, "#{__dir__}/commands/network"
    autoload :Version, "#{__dir__}/commands/version"

    register('network', Network)
    register('version', Version, aliases: ['--version'])
  end
end
