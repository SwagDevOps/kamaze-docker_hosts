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
  autoload :Command, "#{__dir__}/cli/command"
  autoload :Rouge, "#{__dir__}/cli/rouge"

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
    require_relative 'cli/command/interrupt_error'

    result = commands.get(arguments)

    return usage(result, out) unless result.found?

    execute(*parse(result, out))
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

  protected

  # Execute given command.
  #
  # @param [Hanami::CLI::Command] command
  # @param [Hash] args
  # @return [Integer]
  def execute(command, args)
    command.call(args)
    return 0
  rescue Command::InterruptError => e
    warn(e.to_s) unless e.to_s.empty?
    return e.status
  end
end
