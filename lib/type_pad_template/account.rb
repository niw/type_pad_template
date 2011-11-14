module TypePadTemplate
  class Account
    def self.login(username, password)
      account = new.tap do |a|
        a.login(username, password)
      end

      account if account.logged_in?
    end

    attr_reader :login_cookies

    def initialize(login_cookies = nil)
      @login_cookies = login_cookies
    end

    def login(username, password)
      form_element = Request.new("/secure/services/signin", :ssl => true)
        .dispatch
        .response
        .doc
        .at("//form[@id='signin-form-typepad']")

      form = Form.new(form_element).tap do |f|
        f[:username] = username
        f[:password] = password
      end

      @login_cookies = Request.new("/secure/services/signin/save", {
        :ssl => true,
        :method => :post,
        :params => form.to_hash
      }).dispatch
        .response
        .cookies

      self
    end

    def blogs
      return [] unless logged_in?

      request("/dashboard") do |response|
        response
        .doc
        .search("//ul[@id='blogs-list']//a[@class='blog-name']")
        .map do |element|
          if %r{/([0-9a-f]+)/dashboard$} === element["href"]
            id = $1
            Blog.new(self, id, element.text)
          end
        end
        .compact
      end
    end

    def logged_in?
      !@login_cookies.empty?
    end

    def request(path, options = {})
      # FIXME raise a proper exception instead.
      return nil unless logged_in?

      request = Request.new(path, merge_login_cookie_header(options))

      if block_given?
        yield request.dispatch.response
      else
        request
      end
    end

    private

    def merge_login_cookie_header(options)
      options.dup.tap do |options|
        headers = options[:headers] ||= {}
        headers["Cookie"] = [login_cookies_string, headers["Cookie"]].compact.join("; ")
      end
    end

    def login_cookies_string
      @login_cookies.map{|key, value| "#{key}=#{value}"}.join("; ")
    end
  end
end
