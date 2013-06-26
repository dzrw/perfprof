# encoding: UTF-8
module Rack

  # A middleware.
  class PerfProf

    RACK_ACTION = 'rack.perfprof.action'
    PROFILER_KLASS = ::PerfProf::Profiler::Profiler

    class << self

      def profile!(env, ttl, mode, frequency)
        id = PROFILER_KLASS.make_profile_id

        env.merge!("#{RACK_ACTION}" => {
          op: :record,
          id: id,
          ttl: ttl,
          mode: mode,
          frequency: frequency,
        })

        id
      end

    end

    def initialize(app, options = {})
      @app = app
      @options = options
      @profiler = PROFILER_KLASS.new
    end

    def call(env)
      @profiler.stop

      update_env!(env)

      status, headers, body = @app.call(env)

      @profiler.start(start_args(env)) if start?(env)

      if profiling?
        headers.merge!({
          'X-PerfProf-ProfileId' => @profiler.pstate.id,
          'X-PerfProf-TTL' => @profiler.pstate.ttl
        })
      end

      [status, headers, body]
    end

    def profiling?
      @profiler.profiling?
    end

    private

    def update_env!(env)
      return unless profiling?

      opts = {
        'rack.perfprof.profiling' => true,
        'rack.perfprof.id' => @profiler.pstate.id,
        'rack.perfprof.ttl' => @profiler.pstate.ttl
      }

      env.merge!(opts)
    end

    def start?(env)
      env.has_key?(RACK_ACTION)
    end

    def start_args(env)
      env.delete(RACK_ACTION)
    end
  end
end
