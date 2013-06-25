# encoding: UTF-8
require 'spec_helper'

describe ::PerfProf::Profiler::PProfWrapper do
  let(:profiler) { ::PerfProf::Profiler::Profiler.new }
  let(:profiler_args) do
    { id: profiler.class.make_profile_id,
      ttl: 1,
      mode: :cputime,
      frequency: 100 }
  end

  let(:pprof_wrapper) { ::PerfProf::Profiler::PProfWrapper }

  it 'should generate a text summary' do
    profiler.start(profiler_args)

    profile_path = profiler.pstate.profile_path

    5_000_000.times { 1 + 2 + 3 + 4 + 5 }

    profiler.stop

    stdout = pprof_wrapper.pprof(profile_path, :text)

    expect(stdout.is_a?(String)).to eq(true)
    expect(stdout.size > 0).to eq(true)
  end

end
