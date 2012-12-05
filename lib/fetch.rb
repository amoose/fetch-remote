require "fetch/activity"
require "fetch/version"
require 'httparty'
require 'active_support/core_ext'

module Fetch

  API_KEY = 'c3adae5c-6511-48ea-b8e8-c0427f049dd6'
  BASE_URL = 'http://ec2-23-20-101-190.compute-1.amazonaws.com/api/activity?api_key='+API_KEY

  class Query
    attr_accessor :build_query, :type, :result, :klass

    def initialize
      @build_query = {}
      @type = :complete
      @result = []
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
        @build_query = {:query => @build_query}
        request = BASE_URL + "&#{@build_query.to_query}&limit=100"
        Rails.logger "request url: #{request}"
        response = HTTParty.get(request)
        # save the result set here
        response.each do |element|
          @result << klass.new(element)
        end

        @result
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
