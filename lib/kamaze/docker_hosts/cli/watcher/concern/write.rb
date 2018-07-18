# frozen_string_literal: true

# Copyright (C) 2017-2018 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../concern'
autoload :Pathname, 'pathname'
autoload :Tempfile, 'tempfile'
autoload :FileUtils, 'fileutils'

# Provides ``write`` method, exepected to be safe.
module Kamaze::DockerHosts::Cli::Watcher::Concern::Write
  require_relative 'log'

  protected

  # Write file with given content.
  #
  # @param [String|Pathname] filepath
  # @param [String] content
  # @return [Integer]
  def write(filepath, content)
    atomic_write(content.to_s, Tempfile.new(*dots(filepath)), filepath)
  end

  # Tries to write content atomically.
  #
  # @param [String] content
  # @param [Tempfile] tempfile
  # @param [String|Pathname] target
  # @return [Integer]
  def atomic_write(content, tempfile, target)
    Pathname.new(tempfile.path).write(content).tap do
      log_error(Errno::ENOENT, Errno::EPERM, pass: true) do
        apply_perms(tempfile.path, target)
      end

      log_error(Errno::ENOENT, Errno::EPERM) do
        FileUtils.mv(tempfile.path, target)
      end
    end
  end

  # Apply permissions (and ownership) from ``origin`` to ``target``.
  #
  # @param [String] origin
  # @param [String] target
  # @return [File::Stat]
  def apply_perms(origin, target)
    stat(target)&.tap do |stat|
      FileUtils.chown(stat.gid, stat.uid, origin)
      FileUtils.chmod(stat.mode, origin)
    end
  end

  # @return [File::Stat]
  def stat(path)
    log_error(Errno::ENOENT, Errno::EPERM) do
      File.stat(path)
    end
  end

  # Prepare arguments for ``Tempfile`` initialization.
  #
  # @param [String|Pathname] filepath
  # @return [Array<String>]
  def dots(filepath)
    path = Pathname.new(filepath)
    name = path.basename.to_s.gsub(/^\./, '')

    [".#{name}", path.dirname].map(&:to_s)
  end
end
