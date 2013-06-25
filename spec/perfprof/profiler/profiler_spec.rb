# encoding: UTF-8
require 'spec_helper'

describe ::PerfProf::Profiler::Profiler do
  let(:klass) { ::PerfProf::Profiler::Profiler }

  context 'when initialized' do
    it 'should not be profiling' do
      profiler = klass.new
      expect(profiler.profiling?).to eq(false)
    end
  end

  context 'when stop before start' do
    it 'should return false' do
      profiler = klass.new
      expect(profiler.stop).to eq(false)
    end
  end

  context 'when started' do
    it 'should do everything it is supposed to do' do
      profiler = klass.new
      res = profiler.start({
        id: klass.make_profile_id,
        ttl: 2,
        mode: :cputime,
        frequency: 100 })

      # #start should return true:
      expect(res).to eq(true)

      # #pstate should be initialized:
      expect(profiler.profiling?).to eq(true)
      expect(profiler.pstate.ttl).to eq(2)

      tempfile = profiler.pstate.tempfile
      profile_path = profiler.pstate.profile_path

      # The temporary capture file should exist:
      expect(File.exists?(tempfile)).to eq(true)

      # #stop should latch the ttl:
      res = profiler.stop
      expect(res).to eq(false)
      expect(profiler.pstate.ttl).to eq(1)

      res = profiler.stop
      expect(res).to eq(true)

      # #pstate should be released:
      expect(profiler.profiling?).to eq(false)

      # After profiling, the capture file should be moved to
      # it's final destination:
      expect(File.exists?(tempfile)).to eq(false)
      expect(File.exists?(tempfile + '.symbols')).to eq(false)
      expect(File.exists?(profile_path)).to eq(true)
      expect(File.exists?(profile_path + '.symbols')).to eq(true)
    end

    it 'should be reusable' do
      profiler = klass.new

      args = {
        id: klass.make_profile_id,
        ttl: 1,
        mode: :cputime,
        frequency: 100
      }

      profiler.start(args)
      expect(profiler.profiling?).to eq(true)

      profiler.stop
      expect(profiler.profiling?).to eq(false)

      args[:id] = klass.make_profile_id

      profiler.start(args)
      expect(profiler.profiling?).to eq(true)

      profiler.stop
      expect(profiler.profiling?).to eq(false)
    end
  end

end
