# frozen_string_literal: true

# Copyright (C) 2017-2018 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative 'base_file'

# Hosts file, with update capabilities.
#
# Sample of use:
#
# ```ruby
# hosts = File.new('/etc/hosts')
# hosts.update!(Network.new)
# puts hosts
# ```
class Kamaze::DockerHosts::File < Kamaze::DockerHosts::BaseFile
  # Get networks, indexed by names.
  #
  # @return [nil|Hash{Symbol => Kamaze::DockerHosts::Network}]
  attr_reader :networks

  # Get a new section populated with network records.
  #
  # @return [Aef::Hosts::Section]
  def section(name)
    begin
      network = self.networks.fetch(name.to_sym).to_h
    rescue KeyError
      raise ArgumentError, "#{name} not in #{networks.keys}"
    end

    Hosts::Section.new(name, elements: []).tap do |section|
      network.to_h.each do |host, records|
        section.elements.push(Aef::Hosts::Entry.new(records.fetch(0), host))
      end
    end
  end

  def update!(*args)
    self.elements = self.update(*args).elements

    self
  end

  # Update hosts with given network.
  #
  # @param [Kamaze::DockerHosts::Network] network
  # @param [String|Symbol] name
  # @return [self]
  def update(network, name = :containers)
    self.networks = self.networks.to_h.merge(name.to_sym => network)
    self.updating = name.to_sym

    update_on(self.class.new(*[path].compact)).tap do
      self.updating = nil
    end
  end

  protected

  # @type [Hash]
  attr_writer :networks

  # Used during update.
  #
  # This attribute has a very short lifecycle, and SHOULD be nullified
  # when update is considered as done.
  #
  # @type [Symbol|nil]
  attr_accessor :updating

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength

  # Applies update on given instance.
  #
  # @param [self] instance
  # @return [self]
  def update_on(instance)
    instance.tap do |hosts|
      hosts.elements.delete_if do |elem|
        elem.is_a?(Aef::Hosts::Section) and elem.name == self.updating.to_s
      end.tap do
        loop do
          break unless hosts.elements.last.is_a?(Aef::Hosts::EmptyElement)
          hosts.elements.delete_at(-1)
        end
      end.tap do
        args = [
          hosts.elements.empty? ? nil : Aef::Hosts::EmptyElement.new,
          section(updating)
        ].compact

        hosts.elements.push(*args)
      end
    end
  end

  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength
end
