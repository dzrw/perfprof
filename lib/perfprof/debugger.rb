# encoding: utf-8
module PerfProf
  # A simple, inline version of the profiler for use in, say, pry.
  def self.profile(ttl = 250, mode = :cputime, frequency = 100)
    return unless block_given?

    opts = {
      id: ::PerfProf::Profiler::Profiler.make_profile_id,
      ttl: 1,
      mode: mode,
      frequency: frequency
    }

    profiler = ::PerfProf::Profiler::Profiler.new
    profiler.start(opts)

    begin
      result = ttl.times { yield }
    ensure
      profiler.stop

      path = ::PerfProf::Profiler::ProfilerStore.make_profile_path(opts[:id])
      data = ::PerfProf::Profiler::PProfWrapper.pprof(path, :text, {})

      puts data
    end

    result
  end
end
