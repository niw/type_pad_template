module TypePadTemplate
  class Request
    DEFAULT_HOST_NAME = "www.typepad.com"

    def self.dispatch
      hydra.run
    end

    def self.hydra
      @@hydra ||= Typhoeus::Hydra.new
    end

    def initialize(url_or_path, options = {})
      @url_or_path = url_or_path
      @options = options
    end

    def enqueue(&block)
      request.on_complete = lambda do |response|
        block.call(Response.new(response))
      end
      self.class.hydra.queue(request)
      self
    end

    def dispatch
      hydra = Typhoeus::Hydra.new
      hydra.queue(request)
      hydra.run
      self
    end

    def response
      @response ||= Response.new(request.response) if request.response
    end

    private

    def ssl?
      @options[:ssl]
    end

    def protocol
      ssl? ? "https" : "http"
    end

    def url
      @url ||= begin
        uri = URI.parse(@url_or_path)
        unless uri.scheme
          "#{protocol}://#{DEFAULT_HOST_NAME}#{uri.path}"
        else
          uri.to_s
        end
      end
    end

    def request
      @request ||= Typhoeus::Request.new(url, @options.merge({
        :disable_ssl_peer_verification => ssl?
      }))
    end
  end
end
