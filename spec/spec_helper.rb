# encoding: UTF-8

require 'perfprof'

module Spec
  class MockMiddleware
    def initialize(app = nil, options = nil)
      [app, options]
    end

    def call(env)
      env
    end
  end
end
