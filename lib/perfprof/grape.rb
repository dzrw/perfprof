# encoding: utf-8

if defined?(Grape::API) == 'constant' && Grape::API.class == Class

  puts '[PerfProf] Grape detected'

  module PerfProf::Grape
    def automount(klass)
      defn = defined?(DataAcquisition::Platform::Web::Grape::Automount)
      if defn == 'constant'
        mod = DataAcquisition::Platform::Web::Grape::Automount
        if mod.class == Module
          klass.include(mod)
          true
        end
      end
    end
  end

  require_relative 'grape/formatters/pprof_text_formatter'
  require_relative 'grape/resources/performance_profiles'

end
