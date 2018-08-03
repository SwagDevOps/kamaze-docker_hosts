# frozen_string_literal: true

# Copyright (C) 2017-2018 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../watcher'
autoload :Pathname, 'pathname'
autoload :Tempfile, 'tempfile'
autoload :FileUtils, 'fileutils'

# Provides ``write`` method, exepected to be safe.
class Kamaze::DockerHosts::Cli::Watcher::Writer
  require_relative 'concern/log'
  include Kamaze::DockerHosts::Cli::Watcher::Concern::Log

  def initialize(file, logger = nil)
    @file = file
    @logger = logger
    @utils = FileUtils
  end

  # @return [Tempfile]
  def tempfile
    log_error(StandardError, pass: false) do
      Tempfile.new(*dots(self.file))
    end
  end

  # Write given content.
  #
  # @param [String] content
  # @return [Integer]
  def write(content)
    atomic_write(content.to_s, tempfile, self.file)
  end

  protected

  attr_reader :file

  attr_reader :utils

  # Tries to write content atomically.
  #
  # @param [String] content
  # @param [Tempfile] tempfile
  # @param [String|Pathname] target
  # @return [Integer]
  def atomic_write(content, tempfile, target)
    Pathname.new(tempfile.path).write(content).tap do
      log_error(Errno::ENOENT, Errno::EPERM, Errno::EACCES, pass: true) do
        utils.touch(self.file)
        apply_perms(tempfile.path, target)
      end

      utils.mv(tempfile.path, target)
    end
  end

  # Apply permissions (and ownership) from ``origin`` to ``target``.
  #
  # @param [String] origin
  # @param [String] target
  # @return [File::Stat]
  def apply_perms(origin, target)
    stat(target)&.tap do |stat|
      utils.chown(stat.gid, stat.uid, origin)
      utils.chmod(stat.mode, origin)
    end
  end

  # @return [File::Stat]
  def stat(path)
    log_error(Errno::ENOENT, Errno::EPERM) { File.stat(path) }
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
