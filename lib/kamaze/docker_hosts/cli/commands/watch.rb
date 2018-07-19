# frozen_string_literal: true

# Copyright (C) 2017-2018 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../commands'
require 'sys/proc'
require 'yaml'

class Kamaze::DockerHosts::Cli
  # Hosts watcher.
  #
  # Audit usage consumption:
  #
  # ```sh
  # pidof docker-hosts | sed 's/\s\+/\n/g' | \
  #  while read pid; do ps -p $pid -o %cpu,%mem,rss,vsz,cmd; done
  # ```
  class Commands::Watch < Command
    register 'watch'
    enable_network
    desc 'Start watcher'

    option :input, \
           desc: 'File read',
           aliases: ['-i'],
           default: config.watcher.file
    option :'run-once', \
           type: :boolean,
           default: false,
           desc: 'Run once'
    option :fork, \
           type: :boolean,
           default: true,
           desc: 'Fork into background'
    option :lock, \
           type: :boolean,
           default: true,
           desc: 'Lock process'
    option :pidfile, \
           desc: 'Create pid file',
           aliases: ['-P'],
           default: config.watcher.pidfile % { progname: Sys::Proc.progname }

    def call(**options)
      configure(options)

      begin
        watch(options)
      rescue Kamaze::DockerHosts::Cli::Watcher::FlockError => e
        halt(:ENOLCK, e.message)
      rescue StandardError => e
        halt(:EOPNOTSUPP, e.message)
      end
    end

    protected

    def config
      super&.tap do |c|
        if c.watcher.pidfile
          c.watcher.pidfile = c.watcher.pidfile % {
            progname: Sys::Proc.progname
          }
        end
      end
    end

    # @param [Hash] options
    def watch(options)
      file   = options.fetch(:input)
      method = options.fetch(:fork) ? :fork : :lock
      action = options.fetch(:'run-once') ? :update : :watch

      options[:pidfile] = nil unless options[:lock]

      self.config.tap do |config|
        config.watcher[:pidfile] = options[:pidfile]

        Kamaze::DockerHosts::Cli::Watcher
          .configure(config, network, file)
          .public_send(method) { |watcher| watcher.public_send(action) }
      end
    end
  end
end
