# frozen_string_literal: true

# Copyright (C) 2017-2018 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require 'hanami/cli'
require_relative '../cli'
require_relative '../network'
require_relative '../configurator'

# @abstract
class Kamaze::DockerHosts::Cli::Command < Hanami::CLI::Command
  autoload :InterruptError, "#{__dir__}/command/interrupt_error"

  class << self
    protected

    # Register command.
    #
    # @param [String] name
    # @param [Hash] options
    def register(name, options = {})
      registry = Kamaze::DockerHosts::Cli::Commands

      registry.register(name, self, **options)
    end

    # Enable network.
    #
    # Implies ``configurable``.
    #
    # @see #network()
    def enable_network
      configurable
      # rubocop:disable Style/AccessModifierDeclarations
      self.singleton_class.class_eval do
        attr_accessor :network
        protected 'network='
        protected :network
      end
      # rubocop:enable Style/AccessModifierDeclarations
    end

    # Set config option.
    #
    # @see #configure()
    def configurable
      option :config, \
             desc: 'Configuration',
             aliases: ['-c'],
             default: Kamaze::DockerHosts::Configurator.sysconfdir.to_s
    end

    # Get default config.
    #
    # @return [Kamaze::DockerHosts::Configurator::Config]
    def config
      Kamaze::DockerHosts::Configurator.tap do |c|
        config = c.sysconfdir.to_s

        return c.new(config).call
      end
    end

    # Denote current outputs are ``tty``.
    #
    # Possible values are: ``[both, stdout, stderr]``.
    #
    # @param [Symbol|String] out
    # @raise [ArgumentError]
    # @return [Boolean]
    def tty?(out = :both)
      out = out.to_sym
      res = {
        stderr: ($stderr.respond_to?(:tty?) and $stderr.tty?),
        stdout: ($stdout.respond_to?(:tty?) and $stdout.tty?),
      }.tap { |hsh| hsh.merge!(both: (hsh[:stdout] and hsh[:stderr])) }

      begin
        res.fetch(out)
      rescue KeyError
        raise ArgumentError, "#{where} not in #{res.keys.reverse}"
      end
    end
  end

  # Configure (from given options).
  #
  # Sample of use:
  #
  # ```ruby
  # class Hello < Command
  #   configurable
  #
  #   def call(**options)
  #     configure(options)
  #
  #     # access to config
  #     bar = config.foo.bar
  #   end
  # end
  # ```
  #
  # @param [Hash] options
  # @raise [KeyError]
  # @return [self]
  def configure(options)
    config = configurators[:config].call(options.fetch(:config))

    self.singleton_class.__send__(:define_method, :_config) { config }
    # rubocop:disable Style/AccessModifierDeclarations
    self.singleton_class.class_eval { protected :_config }
    # rubocop:enable Style/AccessModifierDeclarations

    self
  end

  protected

  # Interrupt command execution.
  #
  # @param [Symbol|Integer] status
  # @param [String] message
  #
  # @raise [Kamaze::DockerHosts::Cli::InterruptError]
  def halt(status, message = nil)
    InterruptError.new(message).tap do |err|
      err.status = status
      raise err
    end
  end

  # @see #configure
  # @return [Kamaze::DockerHosts::Cli::Config|nil]
  def config
    self._config.clone
  rescue NoMethodError
    nil
  end

  # @todo configure network from ``config``.
  # @return [Kamaze::DockerHosts::Network|nil]
  def network
    network = self.class.__send__(:network)
  rescue NoMethodError
    return
  else
    # rubocop:disable Lint/ShadowingOuterLocalVariable
    # store network
    network || configurators[:network].call(config).tap do |network|
      self.class.__send__('network=', network)
    end
    # rubocop:enable Lint/ShadowingOuterLocalVariable
  end

  # @return [Boolean]
  def tty?(*args)
    self.class.__send__(:tty?, *args)
  end

  private

  # Get configurators.
  #
  # @return [Hash{Symbol => Proc}]
  def configurators
    {
      # @type [Kamaze::DockerHosts::Config]
      config: lambda do |config|
        Kamaze::DockerHosts::Configurator.new(config).call
      end,
      # @type [Kamaze::DockerHosts::Network]
      network: lambda do |config|
        Kamaze::DockerHosts::Network.configure(config)
      end
    }
  end
end
