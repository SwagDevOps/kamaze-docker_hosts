# frozen_string_literal: true
# vim: ai ts=2 sts=2 et sw=2 ft=ruby
# rubocop:disable all
<?rb
@files = [
    '.yardopts',
    'lib/**/*.rb',
    'lib/**/*.yml'
].map { |m| Dir.glob(m) }.flatten.keep_if { |f| File.file?(f) }.sort

self.singleton_class.define_method(:_q) { |input| input.to_s.inspect }
?>

Gem::Specification.new do |s|
  s.name        = #{_q(@name)}
  s.version     = #{_q(@version)}
  s.date        = #{_q(@date)}
  s.summary     = #{_q(@summary)}
  s.description = #{_q(@description)}

  s.licenses    = #{@licenses}
  s.authors     = #{@authors}
  s.email       = #{_q(@email)}
  s.homepage    = #{_q(@homepage)}

  # MUST follow the higher required_ruby_version
  # requires version >= 2.3.0 due to safe navigation operator &
  s.required_ruby_version = ">= 2.3.0"
  s.require_paths = ["lib"]
  s.files = [
    <?rb for file in @files ?>
    #{"%s," % _q(file)}
    <?rb end ?>
  ]

  #{@dependencies.keep(:runtime).to_s.lstrip}
end

# Local Variables:
# mode: ruby
# End:
