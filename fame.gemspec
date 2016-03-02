# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fame/version'

Gem::Specification.new do |spec|
  spec.name          = "fame"
  spec.version       = Fame::VERSION
  spec.authors       = ["Alexander Schuch"]
  spec.email         = ["alexander@schuch.me"]
  spec.summary       = %q{Delightful localization of .storyboard and .xib files, right within Interface Builder.}
  spec.description   = %q{Delightful localization of .storyboard and .xib files, right within Interface Builder. Fame makes it easy to enable specific Interface Builder elements to be translated and exported to localizable .strings files.}
  spec.homepage      = "https://twitter.com/schuchalexander"
  spec.license       = "MIT"

  spec.files         = Dir["lib/**/*"] + %w{ bin/fame README.md LICENSE }
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.post_install_message = "Please add Fame.swift to your project to enable Interface Builder support.\n-> https://github.com/aschuch/fame/blob/master/platform/Fame.swift"

  spec.add_dependency "commander", "~> 4.0"
  spec.add_dependency "nokogiri", "~> 1.0"
  spec.add_dependency "plist", "~> 3.0"
  spec.add_dependency "colorize", ">= 0.7"

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "pry", ">= 0.10"
end
