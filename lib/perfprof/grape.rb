# encoding: utf-8

if defined?(Grape::API) == 'constant' && Grape::API.class == 'Class'

  puts "[PerfProf] Grape support loaded"

  def self.dap_automount_available?
    klass = DataAcquisition::Platform::Web::Grape::Automount
    defined?(DataAcquisition::Platform::Web::Grape::Automount) == 'constant' && klass.class == 'Module'
  end

  module PerfProf::Grape; end

  require_relative 'grape/formatters/pprof_text_formatter'
  require_relative 'grape/resources/performance_profiles'

end
