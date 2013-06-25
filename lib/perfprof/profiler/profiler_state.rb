# encoding: UTF-8
module PerfProf
  module Profiler

    # A descriptive comment.
    class ProfilerState

      DEFAULT_TTL = 250
      DEFAULT_MODE = :cputime
      DEFAULT_FREQUENCY = 100
      MODES = %w[cputime realtime objects methods].map(&:to_sym)

      attr_reader :id, :ttl, :frequency, :mode

      def initialize(id, ttl, mode, frequency)
        @id = id
        @ttl = clamp(ttl, DEFAULT_TTL, 1..1000)
        @frequency = clamp(frequency, DEFAULT_FREQUENCY, 1..4000)
        @mode = parse_mode(mode)
      end

      def decrement
        @ttl -= 1 unless ttl <= 0
        @ttl
      end

      def pid
        $$
      end

      def tempfile
        ::PerfProf::Profiler::ProfilerStore.tempfile
      end

      def profile_path
        ::PerfProf::Profiler::ProfilerStore.make_profile_path(id)
      end

      private

      def clamp(val, default, range)
        val = val.is_a?(Integer) ? val : default
        val = range.first if val < range.first
        val = range.last if val > range.last
        val
      end

      def parse_mode(mode)
        mode = mode.nil? ? nil : mode.to_sym
        MODES.include?(mode) ? mode : DEFAULT_MODE
      end

    end
  end
end


