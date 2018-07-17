# frozen_string_literal: true

# Copyright (C) 2017-2018 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../concern'

# Configurable.
#
# @see Kamaze::DockerHosts::Config
module Kamaze::DockerHosts::Cli::Watcher::Concern::Configurable
  class << self
    def included(base)
      base.extend(ClassMethods)
    end
  end

  # Pass methods seens as configurable to protected.
  #
  # @return [self]
  def attrs_lock!
    self.class.configurables.each do |method|
      # rubocop:disable Style/AccessModifierDeclarations
      self.singleton_class.class_eval { protected "#{method}=" }
      # rubocop:enable Style/AccessModifierDeclarations
    end

    self
  end

  # Class methods
  module ClassMethods
    def configurables
      @configurables.to_a.clone
    end

    protected

    def configurables=(configurables)
      @configurables = configurables.to_a
    end
  end
end
