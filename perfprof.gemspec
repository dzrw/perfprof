# -*- encoding: utf-8 -*-
require File.expand_path('../lib/perfprof/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = "perfprof"
  s.version     = PerfProf::VERSION
  s.authors     = ["David Zarlengo"]
  s.email       = ["david.zarlengo@gmail.com"]
  s.homepage    = "http://github.com/politician/perfprof"
  s.summary     = %q{Middleware for profiling Rack-compatible apps using perftools.rb}
  s.description = %q{Middleware for profiling Rack-compatible apps using perftools.rb}

  #s.rubyforge_project = "rack-perftools_profiler"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  
  s.add_dependency 'perftools.rb', '= 2.0.0'
  s.add_dependency 'rack',         '= 1.5.1'
  s.add_dependency 'rake',         '= 10.0.3'
  s.add_dependency 'pry',                    '= 0.9.11.4'
  s.add_dependency 'pry-doc',                '= 0.4.4'
  s.add_dependency 'pry-debugger',           '= 0.2.1' if RUBY_ENGINE == 'ruby'

  s.add_development_dependency 'rspec',                   '= 2.13'
 
end
