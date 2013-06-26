# encoding: utf-8

module PerfProf::Grape::Formatters
  module PProfGifFormatter

    PRINTER = :gif

    def self.call(object, env)
      object # Because Reek™

      inputfile = env['rack.pprof.inputfile']
      options = {}

      if ::File.exists?(inputfile)
        ::PerfProf::Profiler::PProfWrapper.pprof(inputfile, PRINTER, options)
      end
    end
  end
end
