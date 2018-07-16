# frozen_string_literal: true

# Copyright (C) 2017-2018 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../concern'

# Signal management.
module Kamaze::DockerHosts::Cli::Watcher::Concern::Signal
  protected

  def manage_signals(signals = ['INT', 'TERM', 'QUIT', 'HUP'])
    signals.each { |signal| trap_signal(signal) }
  end

  def trap_signal(signal)
    Signal.trap(signal) do
      warn("signal: #{signal}")
      (signal == 'HUP').tap do |hup|
        update(mode: hup ? :updated : :rescued, signal: signal)

        unless hup
          File.unlink(self.pidfile)
          exit(0)
        end
      end
    end
  end
end
