# encoding: UTF-8
require 'spec_helper'

module Spec

  # Because Reek™
  class NoContentMiddleware
    def call(env)
      env # Because Reek™
      [204, {}, {}]
    end
  end

  # Because Reek™
  class StartProfilerMiddleware
    def initialize(app, options = {})
      @app = app
      @options = options
    end

    def call(env)
      return [200, {}, {}] if env.has_key?('spec.noprofile')

      ttl = @options[:ttl]
      mode = @options[:mode]
      frequency = @options[:frequency]

      ::Rack::PerfProf.start_profiling(env, ttl, mode, frequency)

      [200, {}, {}]
    end
  end
end

describe ::Rack::PerfProf do

  context 'when a nested middleware does not start profiling' do
    let(:subj) do
      ::Rack::PerfProf.new(
        ::Spec::NoContentMiddleware.new)
    end

    it 'should not start profiling' do
      expect(subj.profiling?).to eq(false)

      subj.call(env = {})
      expect(subj.profiling?).to eq(false)
    end

    it 'should not set the perfprof environment keys' do
      expect(subj.profiling?).to eq(false)

      subj.call(env = {})
      expect(env.has_key?('rack.perfprof.profiling')).to eq(false)
      expect(env.has_key?('rack.perfprof.id')).to eq(false)
      expect(env.has_key?('rack.perfprof.ttl')).to eq(false)
    end
  end

  context 'when a nested middleware requests to start profiling' do
    let(:subj) do
      ::Rack::PerfProf.new(
        ::Spec::StartProfilerMiddleware.new(nil, { ttl: 2 }))
    end

    it 'should start then stop profiling' do
      expect(subj.profiling?).to eq(false)

      subj.call(env = {})
      expect(subj.profiling?).to eq(true)

      subj.call(env = { 'spec.noprofile' => true })
      expect(subj.profiling?).to eq(true)

      # Since we were profiling, these rack environment vars should be set:
      expect(env.has_key?('rack.perfprof.profiling')).to eq(true)
      expect(env.has_key?('rack.perfprof.id')).to eq(true)
      expect(env.has_key?('rack.perfprof.ttl')).to eq(true)

      # After the TTL expires, profiling should cease:
      subj.call(env = { 'spec.noprofile' => true })
      expect(subj.profiling?).to eq(false)
    end
  end
end
