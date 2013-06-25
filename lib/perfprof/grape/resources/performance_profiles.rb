# encoding: utf-8

module PerfProf::Grape::Resources

  # A resource which manages a collection of performance profiles.
  class PerformanceProfiles < Grape::API

    if dap_automount_available?
      include DataAcquisition::Platform::Web::Grape::Automount
    end

    resource :performance_profiles do
      content_type :pprof, 'text/pprof'
      formatter :pprof, PProfTextFormatter

      helpers do
        def fetch_profile(id)
          klass = ::PerfProf::Profiler::ProfileStore
          res = klass.get(id)
          return nil unless res
          env['rack.pprof.inputfile'] = res[:path]
          res[:resource]
        end

        def delete_profile(id)
          klass = ::PerfProf::Profiler::ProfileStore
          klass.delete(id)
        end

        def start_recording(ttl, mode, frequency)
          id = Rack::PerfProf.start_profiling(env, ttl, mode, frequency)
          { id: id }
        end
      end

      # GET /performance_profiles
      desc 'Returns the collection of performance profiles on this server.'
      get do
        $hostname = Socket.gethostname unless $hostname

        status 200
        { hostname: $hostname,
          profiles: Profiler.profiles }
      end

      # GET /performance_profiles/:id
      get :id do |id|
        res = fetch_profile(id)
        if res
          status 200
          res
        else
          status 404
        end
      end

      # POST /performance_profiles
      params do
        optional :ttl, type: Integer, default: 250,
          desc: 'The number of requests to process before profiling stops'
        optional :mode, type: String, default: 'cputime',
          desc: 'The sampling mode'
        optional :frequency, type: Integer, default: 100,
          desc: 'The sampling frequency'
      end
      post do
        res = start_recording(params.pluck(:ttl, :mode, :frequency))

        status 202
        header 'Location', "/performance_profiles/#{res[:id]}"

        res
      end

      # DELETE /performance_profiles/:id
      delete :id do |id|
        if delete_profile(id)
          status 204
        else
          status 404
        end
      end
    end
  end
end
