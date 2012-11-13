module Fetch
  class Activity
    def initialize hsh={}
      @metadata = hsh
    end

    def self.where hsh
      q = Query.new.where hsh
      q.klass = Fetch::Activity
      q
    end

    def save
      if @metadata["id"].nil?
        HTTParty.post BASE_URL, :body => @metadata.to_json, :headers => { 'Content-Type' => 'application/json' }
      else
      end
    end

    def method_missing method_name, *args, &block
      method_name = method_name.to_s
      if method_name.to_s.last == "="
        @metadata[method_name[0..-2]] = args.first
      end

      @metadata[method_name]
    end
  end
end
