# frozen_string_literal: true
# vim: ai ts=2 sts=2 et sw=2 ft=ruby
# rubocop:disable all
<?rb self.singleton_class
         .define_method(:quote) { |input| input.to_s.inspect } ?>

Gem::Specification.new do |s|
  s.name        = #{quote(@name)}
  s.version     = #{quote(@version)}
  s.date        = #{quote(@date)}
  s.summary     = #{quote(@summary)}
  s.description = #{quote(@description)}

  s.licenses    = #{@licenses}
  s.authors     = #{@authors}
  s.email       = #{quote(@email)}
  s.homepage    = #{quote(@homepage)}

  # MUST follow the higher required_ruby_version
  # requires version >= 2.3.0 due to safe navigation operator &
  s.required_ruby_version = ">= 2.3.0"
  s.require_paths = ["lib"]
  s.bindir        = "bin"
  s.executables   = "docker-hosts"
  s.files = [
    ".yardopts",
    "bin/*",
    "lib/**/*.rb",
    "lib/**/*.yml",
  ].map { |m| Dir.glob(m) }.flatten.sort

  #{@dependencies.keep(:runtime).to_s.lstrip}
end

# Local Variables:
# mode: ruby
# End:
