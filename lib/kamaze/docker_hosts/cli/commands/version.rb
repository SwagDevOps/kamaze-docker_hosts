# frozen_string_literal: true

require_relative '../commands'

# Version
class Kamaze::DockerHosts::Cli::Commands::Version < Hanami::CLI::Command
  desc 'Print version'

  def call(*)
    ["#{progname} #{version}",
     nil,
     version.license_header].join("\n").tap do |str|
      $stdout.puts(str)
    end
  end

  protected

  # @return [Kamaze::DockerHosts::VERSION]
  def version
    Kamaze::DockerHosts::VERSION
  end

  # @return [String]
  def progname
    $PROGRAM_NAME
  end
end
