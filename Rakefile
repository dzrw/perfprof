# encoding: utf-8

require 'bundler/gem_tasks'

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  rspec_opts = %w[ --color
                   --format documentation
                   --order random ].join(' ')
  spec.rspec_opts = rspec_opts
end
