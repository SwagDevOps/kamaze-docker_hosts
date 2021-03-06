# frozen_string_literal: true

# Copyright (C) 2017-2018 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../concern'
require 'syslog/logger'
require 'sys/proc'

# Provides methods related to logging.
module Kamaze::DockerHosts::Cli::Watcher::Concern::Log
  protected

  # Get logger.
  #
  # @return [Logger]
  def logger
    @logger
  end

  # Log a message at the ``severity`` log level.
  #
  # @param [String] message
  # @param [Symbol] severity
  # @return [self]
  #
  # @see https://ruby-doc.org/stdlib-2.4.0/libdoc/logger/rdoc/Logger.html
  def log(message, severity = :INFO)
    # rubocop:disable Lint/ShadowingOuterLocalVariable
    Logger.const_get(severity).tap do |severity|
      logger&.add(severity, message)
    end
    # rubocop:enable Lint/ShadowingOuterLocalVariable

    self
  end

  # Log error happening during block execution.
  #
  # @param [Array<Class>] types
  # @param [Boolean] pass
  # @raise [Exception]
  # @return [nil|Object]
  def log_error(*types, pass: true)
    yield
  rescue *types => e
    ('[%<type>s] %<message>s - %<from>s - %<btin>s' % {
      type: e.class,
      message: e.message,
      from: caller_locations(2..2).first, # caller_locations[1],
      btin: e.backtrace.first
    }).tap { |message| log(message, :ERROR) }

    pass ? nil : raise(e)
  end

  # @return [Syslog::Logger]
  def syslog
    Syslog::Logger.new(Sys::Proc.progname)
  end
end
