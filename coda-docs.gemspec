lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "coda_docs/version"

Gem::Specification.new do |spec|
  spec.name          = "coda-docs"
  spec.version       = CodaDocs::VERSION
  spec.authors       = ["David Pedersen"]
  spec.email         = ["david.pdrsn@gmail.com"]

  spec.summary       = %q{Wrapper of Coda's REST API}
  spec.description   = %q{Wrapper of Coda's REST API}
  spec.homepage      = "http://github.com/tonsser/coda-docs"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"

  spec.add_dependency "rest-client", "~> 2.0.2"
  spec.add_dependency "takes_macro", "~> 1.0.0"
end
