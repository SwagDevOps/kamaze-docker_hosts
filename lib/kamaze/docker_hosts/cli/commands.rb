# frozen_string_literal: true

# Copyright (C) 2017-2018 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

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
           .map { |fp| fp.gsub(/\.rb$/, '') }
      end
    end

    registrables.each do |command|
      require_relative command
    end
  end
end
