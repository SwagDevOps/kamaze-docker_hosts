# frozen_string_literal: true

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
