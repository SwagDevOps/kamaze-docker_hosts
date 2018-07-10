# frozen_string_literal: true

require_relative '../commands'

class Kamaze::DockerHosts::Cli
  # Display hosts
  class Commands::Hosts < Command
    register 'hosts'
    enable_network
    desc 'Display hosts'

    def call(**options)
      configure(options)

      file.update!(network).tap do |content|
        $stdout.puts(content)
      end
    end

    protected

    # Get file.
    #
    # @return [Kamaze::DockerHosts::File]
    def file
      require_relative '../../file'

      Kamaze::DockerHosts::File.new
    end
  end
end
