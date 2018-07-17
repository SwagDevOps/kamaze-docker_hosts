# frozen_string_literal: true

# Copyright (C) 2017-2018 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

# rubocop:disable Style/Documentation

module Kamaze
end

# rubocop:enable Style/Documentation

# Namespace module
module Kamaze::DockerHosts
  autoload :VERSION, "#{__dir__}/docker_hosts/version"
  autoload :File, "#{__dir__}/docker_hosts/file"
  autoload :Network, "#{__dir__}/docker_hosts/network"
end
