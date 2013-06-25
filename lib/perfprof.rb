# encoding: utf-8

class Hash
  def pluck(*keys)
    keys.map { |key| self[key] }
  end
end

module PerfProf; end

require_relative 'perfprof/profiler'
require_relative 'perfprof/grape'
require_relative 'perfprof/rack'
