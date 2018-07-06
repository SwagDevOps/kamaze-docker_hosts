# frozen_string_literal: true

module Kamaze
end

# Namespace module
module Kamaze::DockerHosts
  autoload :VERSION, "#{__dir__}/docker_hosts/version"
  autoload :File, "#{__dir__}/docker_hosts/file"
  autoload :Network, "#{__dir__}/docker_hosts/network"
end
