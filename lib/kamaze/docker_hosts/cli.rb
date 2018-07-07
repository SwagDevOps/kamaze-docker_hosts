# frozen_string_literal: true

require_relative '../docker_hosts'
require 'hanami/cli'

# Command Line Interface (CLI)
#
# Sample of use:
#
# ```ruby
# Cli.new.tap { |cli| exit cli.call }
# ```
class Kamaze::DockerHosts::Cli < Hanami::CLI
  autoload :Commands, "#{__dir__}/cli/commands"
  autoload :InterruptError, "#{__dir__}/cli/interrupt_error"

  # Create a new instance
  def initialize
    super(Commands)
  end

  # Invoke the CLI
  #
  # @param [Array<string>] arguments the command line arguments
  # @param [IO] out the standard output
  # @return [Integer]
  def call(arguments: ARGV.clone.freeze, out: $stdout)
    result = commands.get(arguments)

    return usage(result, out) unless result.found?

    # Callbacks are removed
    parse(result, out).tap do |command, args|
      begin
        return command.call(args).to_i
      rescue Kamaze::DockerHosts::Cli::Command::InterruptError => e
        warn(e)
        return e.status
      end
    end
  end

  # Prints the command usage and exit.
  #
  # @param [Hanami::CLI::CommandRegistry::LookupResult] result
  # @param [IO] out
  # @return [Integer]
  def usage(result, out)
    super
  rescue SystemExit
    return 22
  end
end
