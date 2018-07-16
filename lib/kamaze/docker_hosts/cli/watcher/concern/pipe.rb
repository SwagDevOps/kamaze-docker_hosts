# frozen_string_literal: true

# Copyright (C) 2017-2018 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../concern'
autoload :Cod, 'cod'

# Provides ``write`` method, exepected to be safe.
module Kamaze::DockerHosts::Cli::Watcher::Concern::Pipe
  protected

  def pipe_init(key)
    @pipes ||= {}
    @pipes[key] ||= Cod.pipe
  end

  def pipe_put(key, value)
    @pipes.fetch(key).put(value)
  end

  def pipe_get(key, ttw = nil)
    return @pipes.fetch(key).get unless ttw

    begin
      Timeout.timeout(ttw) { @pipes.fetch(key).get }
    rescue Timeout::Error
      nil
    end
  rescue Cod::ConnectionLost
    nil
  end
end
