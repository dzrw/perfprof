# encoding: UTF-8
module PerfProf
  module Profiler

    # A descriptive comment.
    class Profiler

      PStore = ::PerfProf::Profiler::ProfilerStore

      class << self
        def make_profile_id
          PStore.make_profile_id
        end
      end

      attr_reader :pstate

      def initialize
        @perftools_loaded = false
      end

      def start(opts)
        return false if profiling?

        # Because Reek™
        args = opts.pluck(:id, :ttl, :mode, :frequency)
        set_profiler_state(*args)

        load_perftools

        if dryrun?
          PStore.touch_tempfile
        else
          PerfTools::CpuProfiler.start(PStore.tempfile)
        end

        true
      end

      def stop
        return false unless profiling? && pstate.decrement <= 0

        PerfTools::CpuProfiler.stop unless dryrun?

        PStore.capture_tempfile(pstate.id)

        unset_profiler_state

        true
      end

      def dryrun?
        false # TODO
      end

      def profiling?
        !pstate.nil?
      end

      private

      def unset_profiler_state
        unset_env_vars
        @pstate = nil
      end

      def set_profiler_state(*args)
        @pstate = ::PerfProf::Profiler::ProfilerState.new(*args)
        set_env_vars(pstate.mode, pstate.frequency)
      end

      def unset_env_vars
        ENV.delete('CPUPROFILE_REALTIME')
        ENV.delete('CPUPROFILE_FREQUENCY')
        ENV.delete('CPUPROFILE_OBJECTS')
        ENV.delete('CPUPROFILE_METHODS')
      end

      def set_env_vars(mode, frequency)
        unset_env_vars

        case mode
        when :realtime;  ENV['CPUPROFILE_REALTIME'] = '1'
        when :objects;   ENV['CPUPROFILE_OBJECTS'] = '1'
        when :methods;   ENV['CPUPROFILE_METHODS'] = '1'
        end

        ENV['CPUPROFILE_FREQUENCY'] = frequency.to_s
      end

      def load_perftools
        unless @perftools_loaded
          require 'perftools'
          @perftools_loaded = true
        end
      end

    end
  end
end



