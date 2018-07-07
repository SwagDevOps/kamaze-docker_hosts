# frozen_string_literal: true

require_relative '../cli'
require 'hanami/cli'

# @abstract
class Kamaze::DockerHosts::Cli::Command < Hanami::CLI::Command
  autoload :InterruptError, "#{__dir__}/command/interrupt_error"

  class << self
    def enable_network
      require_relative '../network'

      Kamaze::DockerHosts::Network.new.tap do |network|
        @network = network

        self.singleton_class.define_method(:network) { network }
        # rubocop:disable Style/AccessModifierDeclarations
        self.singleton_class.class_eval { protected :network }
        # rubocop:enable Style/AccessModifierDeclarations
      end
    end
  end

  protected

  # Interrupt command execution.
  #
  # @param [String] message
  # @param [Symbol|Integer] status
  # @raise [Kamaze::DockerHosts::Cli::InterruptError]
  def interrupt(message, status = :EPERM)
    InterruptError.new(message).tap do |err|
      err.status = status
      raise err
    end
  end

  # @return [Kamaze::DockerHosts::Network|nil]
  def network
    self.class.__send__(:network).clone
  rescue NoMethodError
    nil
  end
end
