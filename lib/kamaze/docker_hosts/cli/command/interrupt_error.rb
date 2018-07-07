# frozen_string_literal: true

require_relative '../command'
require_relative '../../errno'

# Exception used to interrupt command execution.
#
# @see Kamaze::DockerHosts::Cli::Command#interrupt()
# @see Kamaze::DockerHosts::Cli#call()
class Kamaze::DockerHosts::Cli::Command::InterruptError < ::StandardError
  include Kamaze::DockerHosts::Errno
  attr_reader :status
  attr_reader :message

  # @param [String] message
  def initialize(message)
    super
    @message = message
    self.status = :EPERM
  end

  # @return [Integer]
  def to_s
    message.to_s
  end

  # @return [Integer]
  def to_i
    status
  end

  # Set status
  #
  # @param [Integer|Symbol] status
  def status=(status)
    @status = status.is_a?(Integer) ? status : errno(status)
  end
end
