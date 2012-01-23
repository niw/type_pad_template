require "thor"
require "yaml"
require "highline"

module TypePadTemplate
  SESSION_FILE = File.expand_path("~/.type_pad_template_session")

  class Command < Thor
    def self.blog_id_option
      method_option(:blog_id, {
        :type => :string,
        :aliases => "-b",
        :required => true,
        :desc => "Blog ID which blogs command shows."
      })
    end

    def self.directory_option
      method_option(:directory, {
        :type => :string,
        :aliases => "-d",
        :desc => "Path to templates directory."
      })
    end

    def self.pattern_option
      method_option(:pattern, {
        :type => :string,
        :aliases => "-p",
        :desc => "Pattern to select templates."
      })
    end

    desc "login", "Login to TypePad."
    method_option :username, :type => :string, :aliases => "-u", :desc => "Login email address."
    method_option :password, :type => :string, :aliases => "-p", :desc => "Password."
    def login
      username = options[:username] || highline.ask("Enter login email address: ")
      password = options[:password] || highline.ask("Enter password: "){|q| q.echo = false }

      account = Account.login(username, password)

      File.open(SESSION_FILE, "w") do |file|
        YAML.dump(account.login_cookies, file)
      end
    end

    desc "logout", "Logout from TypePad."
    def logout
      File.unlink(SESSION_FILE)
    end

    desc "blogs", "List current blogs."
    def blogs
      print_table account.blogs.map{|blog| [blog.blog_id, blog.name]}
    end

    desc "templates", "List current templates."
    blog_id_option
    def templates
      print_table blog.templates.map{|template| [template.filename, template.name]}
    end

    desc "download", "Download templates from TypePad."
    blog_id_option
    directory_option
    pattern_option
    def download(filenames = nil)
      pattern_select(blog.templates).each do |template|
        template.enqueue_get do |text|
          say "Downloaded #{template.filename}"
          File.open(File.join(directory, template.filename), "w"){|f| f.write(text)}
        end
      end
      Request.dispatch
    end

    desc "upload", "Upload templates from local."
    blog_id_option
    directory_option
    pattern_option
    def upload
      pattern_select(blog.templates).each do |template|
        path = File.join(directory, template.filename)
        template.enqueue_post(File.read(path)) do |response|
          say "Uploaded #{template.filename}"
        end
      end
      Request.dispatch
    end

    private

    def account
      @account ||= Account.new(YAML.load(File.read(SESSION_FILE)))
    end

    def blog
      @blog ||= account.blogs.find{|blog| blog.blog_id == options[:blog_id]}
    end

    def directory
      @directory ||= File.expand_path(options[:directory] || Dir.pwd)
    end

    def pattern_select(list)
      return list unless options[:pattern]
      list.select do |item|
        File.fnmatch(options[:pattern], item.filename)
      end
    end

    def highline
      @highline ||= HighLine.new
    end
  end
end
