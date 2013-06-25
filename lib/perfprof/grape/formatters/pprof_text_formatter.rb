# encoding: utf-8

module PerfProf::Grape::Formatters
  module PProfTextFormatter

    PRINTER = :text

    def self.call(object, env)
      object # Because Reek™

      inputfile = env['rack.pprof.inputfile']
      options = {}

      if ::File.exists?(inputfile)
        PProfWrapper.pprof(inputfile, PRINTER, options)
      end
    end
  end
end
