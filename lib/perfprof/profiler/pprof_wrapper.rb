# encoding: utf-8
module PerfProf
  module Profiler

    module PProfWrapper
      def pprof(inputfile, printer, options)
        args = build_command(inputfile, printer, options)
        stdout, stderr, status = shell_exec(*args)

        full_command = args.join(' ')
        if status != 0
          raise ProfilingError.new(
            "Running the command '#{full_command}' exited with status #{status}",
            stderr)
        elsif stdout.length == 0 && stderr.length > 0
          raise ProfilingError.new(
            "Running the command '#{full_command}' failed to generate a file",
            sstderr)
        else
          stdout
        end
      end

      def build_command(inputfile, printer, options)
        bundler      = options.fetch('bundler') { nil }
        ignore       = options.fetch('ignore') { nil }
        focus        = options.fetch('focus') { nil }
        nodecount    = options.fetch('nodecount') { nil }
        nodefraction = options.fetch('nodefraction') { nil }

        args = ["--#{printer}"]
        args << "--ignore=#{ignore}" if ignore
        args << "--focus=#{focus}" if focus
        args << "--nodecount=#{nodecount}" if nodecount
        args << "--nodefraction=#{nodefraction}" if nodefraction
        args << inputfile
        cmd = ['pprof.rb'] + args
        cmd = ['bundle', 'exec'] + cmd if bundler
        cmd
      end

      def shell_exec(*args)
        out = err = ''
        pid = nil
        exit_status = nil
        status = Open3.popen3(*args) do |stdin, stdout, stderr, wait_thr|
          stdin.close
          pid = wait_thr.pid
          out = stdout.read
          err = stderr.read
          exit_status = wait_thr.value
        end
        [out, err, exit_status]
      end
    end
    
  end
end
