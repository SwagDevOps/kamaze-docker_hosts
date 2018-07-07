# frozen_string_literal: true

require_relative '../cli'
require 'hanami/cli'

# @abstract
class Kamaze::DockerHosts::Cli::Command < Hanami::CLI::Command
  autoload :InterruptError, "#{__dir__}/command/interrupt_error"

  class << self
    protected

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

    # Denote current outputs are ``tty``.
    #
    # Possible values are: ``[both, stdout, stderr]``.
    #
    # @raise [ArgumentError]
    # @return [Boolean]
    def tty?(where = nil)
      res = {
        stderr: ($stderr.respond_to?(:tty?) and $stderr.tty?),
        stdout: ($stdout.respond_to?(:tty?) and $stdout.tty?),
      }.tap { |hsh| hsh.merge!(both: (hsh[:stdout] and hsh[:stderr])) }

      begin
        res.fetch((where || :both).to_sym)
      rescue KeyError
        raise ArgumentError, "#{where} not in #{res.keys.reverse}"
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

  # @return [Boolean]
  def tty?(*args)
    self.class.__send__(:tty?, args)
  end
end
