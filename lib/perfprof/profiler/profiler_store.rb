# encoding: UTF-8
require 'fileutils'

module PerfProf
  module Profiler

    # A descriptive comment.
    class ProfilerStore
      class << self

        def tempfile
          "tmp/profiles/#{$$}.partial"
        end

        def make_profile_id
          "#{Time.now.to_i}_#{$$}"
        end

        def make_profile_path(key)
          "tmp/profiles/#{key}"
        end

        def all
          # Incomplete profiles end with '.partial', and gperftools
          # also writes symbol files which end with '.symbols'.  We
          # don't include either in this collection.
          Dir.glob('tmp/profiles/*').map do |str|
            res = str.match(/(\d+_\d+)$/)
            res.nil? ? nil : res[1]
          end.compact
        end

        def get(key)
          path = make_profile_path(key)
          return nil unless File.exists?(path)
          { resource: { id: key }, path: path }
        end

        def delete(key)
          item = get(key)
          return nil unless item
          File.delete(item[:path])
          item
        end

        def capture_tempfile(key)
          args = [tempfile, make_profile_path(key)]
          FileUtils.mv(*args)
          FileUtils.mv(*args.map { |str| str + '.symbols' })
        end

        def touch_tempfile
          FileUtils.touch(tempfile)
          FileUtils.touch(tempfile + '.symbols')
        end
      end
    end

  end
end
