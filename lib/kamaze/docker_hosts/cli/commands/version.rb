# frozen_string_literal: true

# Copyright (C) 2017-2018 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

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
