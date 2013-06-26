# encoding: utf-8

module PerfProf::Grape::Formatters
  module PProfTextFormatter

    PRINTER = :text

    def self.call(object, env)
      object # Because Reek™

      inputfile = env['rack.pprof.inputfile']

      if !inputfile.nil? && ::File.exists?(inputfile)
        ::PerfProf::Profiler::PProfWrapper.pprof(inputfile, PRINTER, {})
      end
    end
  end
end
