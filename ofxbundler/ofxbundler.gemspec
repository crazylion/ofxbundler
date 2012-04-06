# -*- encoding: utf-8 -*-
require File.expand_path('../lib/ofxbundler/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["crazylion"]
  gem.email         = ["crazylion2@gmail.com"]
  gem.description   = %q{help user to manager their openframes addons }
  gem.summary       = %q{help user to manager their openframes addons }
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "ofxbundler"
  gem.require_paths = ["lib"]
  gem.version       = Ofxbundler::VERSION
end
