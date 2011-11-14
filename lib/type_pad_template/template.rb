module TypePadTemplate
  class Template
    extend Forwardable

    def_delegator :blog, :request

    attr_reader :blog, :name, :filename, :url, :text

    def initialize(blog, name, filename, edit_url)
      @blog = blog
      @name = name
      @filename = filename
      @edit_path = URI.parse(edit_url).path
    end

    def enqueue_get(&block)
      request(@edit_path).enqueue do |response|
        @text = get_text_from_response(response)
        block.call(text)
      end
    end

    def get
      request(@edit_path) do |response|
        @text = get_text_from_response(response)
      end
    end

    def enqueue_post(text, &block)
      request(@edit_path).enqueue do |response|
        form = get_form_for_body(response).tap do |f|
          f[:text] = text
        end
        request_for_form(form).enqueue do |response|
          @text = text
          block.call(response)
        end
      end
    end

    def post(text)
      request(@edit_path) do |response|
        form = get_form_for_body(response).tap do |f|
          f[:text] = text
        end

        response = request_for_form(form).dispatch.response
        @text = text

        response
      end
    end

    private

    def get_form_for_body(response)
      Form.new(
        response
        .doc
        .at("form[@id='template-form']"))
    end

    def get_text_from_response(response)
      response
      .doc
      .at("//form[@id='template-form']//textarea[@name='text']")
      .text
    end

    # FIXME make this works in Form.
    def request_for_form(form)
      request(form.url, {
        :method => form.method,
        :params => form.to_hash
      })
    end
  end
end
