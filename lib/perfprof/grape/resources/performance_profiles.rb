# encoding: utf-8
require 'socket'

module PerfProf::Grape::Resources

  # A resource which manages a collection of performance profiles.
  class PerformanceProfiles < Grape::API

    PerfProf::Grape::automount(self)

    resource :performance_profiles do
      content_type :json, 'application/json'

      content_type :pprof, 'text/pprof'
      formatter :pprof, PerfProf::Grape::Formatters::PProfTextFormatter

      content_type :pprof_gif, 'image/gif'
      formatter :pprof_gif, PerfProf::Grape::Formatters::PProfGifFormatter

      helpers do
        def repository
          ::PerfProf::Profiler::ProfilerStore
        end

        def perfprof
          ::Rack::PerfProf
        end

        def fetch_profile(id)
          res = repository.get(id)
          return nil unless res
          env['rack.pprof.inputfile'] = res[:path]
          res[:resource]
        end

        def delete_profile(id)
          repository.delete(id)
        end

        def create_profile(ttl, mode, frequency)
          id = perfprof.profile!(env, ttl, mode, frequency)
          { id: id }
        end
      end

      # GET /performance_profiles
      desc 'Returns the collection of performance profiles on this server.'
      get do
        $hostname = Socket.gethostname unless $hostname

        status 200
        { hostname: $hostname,
          profiles: repository.all }
      end

      # GET /performance_profiles/:id
      params do
        required :id, type: String, desc: 'Profile Id'
      end
      get ':id' do
        res = fetch_profile(params[:id])
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
        res = create_profile(*params.pluck(:ttl, :mode, :frequency))

        status 202
        header 'Location', "/performance_profiles/#{res[:id]}"

        res
      end

      # DELETE /performance_profiles/:id
      params do
        required :id, type: String, desc: 'Profile Id'
      end
      delete ':id' do
        if delete_profile(params[:id])
          status 204
        else
          status 404
        end
      end
    end
  end
end
