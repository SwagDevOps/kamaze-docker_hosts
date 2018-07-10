# frozen_string_literal: true

require_relative '../cli'
require 'hanami/cli'
require_relative 'command'

class Kamaze::DockerHosts::Cli
  # CLI commands module
  module Commands
    extend Hanami::CLI::Registry

    class << self
      protected

      # Get registrable command files.
      #
      # @return [Array<String>]
      def registrables
        Dir.chdir(__dir__) { Dir.glob('commands/*.rb') }
           .sort
           .map { fp.gsub(/\.rb$/, '') }
      end
    end

    registrables.each do |command|
      require_relative command
    end
  end
end
