module TypePadTemplate
  class Response
    def initialize(response)
      @response = response
    end

    def successful?
      @response.code == 200
    end

    def cookies
      @cokies ||= Array(@response.headers_hash["Set-Cookie"]).inject({}) do |hash, cookie|
        key, value = cookie.split(/;/, 2).first.split(/=/, 2)
        hash[key] = value
        hash
      end
    end

    def doc
      @doc ||= Nokogiri::HTML.parse(@response.body)
    end
  end
end
