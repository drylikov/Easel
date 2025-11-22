
# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "easel/version"

Gem::Specification.new do |s|
  s.name        = "easel"
  s.version     = Easel::VERSION
  s.authors     = ["Mat Trudel"]
  s.email       = ["mat@geeky.net"]
  s.homepage    = ""
  s.summary     = %q{Easel lets your Mongoid models speak RDF}
  s.description = %q{Easel lets your Mongoid models speak RDF}

  s.rubyforge_project = "easel"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "rspec"

  s.add_runtime_dependency "mongoid"
  s.add_runtime_dependency "rdf"
  s.add_runtime_dependency "rdf-xml"
  s.add_runtime_dependency "activesupport"
end
