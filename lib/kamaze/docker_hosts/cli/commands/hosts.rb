# frozen_string_literal: true

require_relative '../commands'

class Kamaze::DockerHosts::Cli
  # Display hosts
  class Commands::Hosts < Command
    register 'hosts'
    enable_network
    desc 'Display hosts'

    include Kamaze::DockerHosts::Cli::Rouge

    def call(**options)
      configure(options)

      file.update!(network).tap do |content|
        output = tty?(:stdout) ? hl(content, :Conf) : content

        $stdout.puts(output)
      end
    end

    protected

    # Get file.
    #
    # @return [Kamaze::DockerHosts::File]
    def file
      Kamaze::DockerHosts::File.new
    end
  end
end
