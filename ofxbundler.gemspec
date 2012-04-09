# -*- encoding: utf-8 -*-
require File.expand_path('../lib/ofxbundler/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["crazylion"]
  gem.email         = ["crazylion2@gmail.com"]
  gem.description   = %q{help user to manager their openframeworks addons }
  gem.summary       = %q{help user to manager their openframeworks addons }
  gem.homepage      = "https://github.com/crazylion/ofxbundler"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "ofxbundler"
  gem.require_paths = ["lib"]
  gem.version       = Ofxbundler::VERSION

  gem.add_development_dependency 'faraday'
  gem.add_development_dependency 'nokogiri'
  gem.add_development_dependency 'rubyzip'
  gem.add_runtime_dependency 'faraday'
  gem.add_runtime_dependency 'nokogiri'
  gem.add_runtime_dependency 'rubyzip'
end
