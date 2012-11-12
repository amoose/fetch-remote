require "fetch/version"
require 'httparty'
require 'active_support'

module Fetch

  BASE_URL = 'http://0.0.0.0:3000/api/activity'

  class Activity
    attr_accessor :build_query, :type, :result

    def initialize
      @build_query = {}
      @type = :complete
      @result = {}
    end    

    def where(expr)
      if expr.is_a?(Hash) # i.e. Fetch.where(:aus_id => '111') 
        @build_query = @build_query.merge(expr)
        @type = :complete
      elsif expr.is_a?(String) # i.e. Fetch.where(:created_at).gt('2012-01-01')
        @build_query = {expr.to_sym => NullObject.new}
        @type = :incomplete
      elsif expr.is_a?(Symbol)
        @build_query = {expr => NullObject.new}
        @type = :incomplete
      else
        # return an exception
        @type = :incomplete
      end
      return self
    end

    # this method shoots the query out and receives its response
    def all()
      if @type == :complete
        request = BASE_URL + "?#{@build_query.to_query}"
        response = HTTParty.get(request)
        # save the result set here
        @result = response
        return response
      else
        raise 'An error has occurred'
      end
    end

    def gt(search_value)
      build_inequality(search_value, 'gt')
    end

    def lt(search_value)
      build_inequality(search_value, 'lt')
    end

    def build_inequality(search_value, type)
      @build_query.each do |k,v|
        if v.instance_of? NullObject
          @build_query = {"#{k}.#{type}" => search_value}
          @type = :complete
          break
        end
      end
      return self
    end

    def inspect()
      @build_query.to_s
    end

  end

  class NullObject
    def method_missing(*args, &block)
      self
    end
  end

end
