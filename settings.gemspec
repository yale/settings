# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'settings/version'

Gem::Specification.new do |spec|
  spec.name          = "settings"
  spec.version       = Settings::VERSION
  spec.authors       = ["yale"]
  spec.email         = ["yale@newslook.com"]
  spec.description   = %q{A general purpose read only EAV settings cache}
  spec.summary       = %q{A general purpose read only EAV settings cache}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
