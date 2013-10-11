# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sample_gem/version'

Gem::Specification.new do |spec|
  spec.name          = "sample_gem"
  spec.version       = SampleGem::VERSION
  spec.authors       = ["Fernando Alonso"]
  spec.email         = ["krakatoa1987@gmail.com"]
  spec.description   = %q{An experimental Rack app gem that autoloads on Rails}
  spec.summary       = %q{Same as description}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "xmpp4r"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
