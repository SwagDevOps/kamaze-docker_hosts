# frozen_string_literal: true

require_relative '../commands'

# Version
class Kamaze::DockerHosts::Cli
  # Display version.
  class Commands::Version < Command
    register 'version', aliases: ['--version']
    desc 'Print version'

    def call(*)
      ["#{progname} #{version}",
       nil,
       version.license_header].join("\n").tap do |str|
        $stdout.puts(str)
      end
    end

    protected

    # Get version.
    #
    # @return [Kamaze::DockerHosts::VERSION]
    def version
      Kamaze::DockerHosts::VERSION
    end

    # Get progname.
    #
    # @return [String]
    def progname
      $PROGRAM_NAME
    end
  end
end
