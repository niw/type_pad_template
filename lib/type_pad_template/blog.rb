module TypePadTemplate
  class Blog
    extend Forwardable

    def_delegator :account, :request

    attr_reader :account, :blog_id, :name

    def initialize(account, blog_id, name)
      @account = account
      @blog_id = blog_id
      @name = name
    end

    def templates
      return [] unless design_id = current_design_id

      request("/site/blogs/#{@blog_id}/design/#{design_id}/templates") do |response|
        response.
        doc.
        search("//td[@class='index-templates' or @class='archive-templates' or @class='template-modules']/a[@class='link']").
        map do |element|
          name = element.text

          output_file_element = element.at("../..//td[@class='output-file']")

          filename = if output_file_element
            output_file_element.text
          else
            "#{name.downcase.gsub(/[\- ]/, "_")}.template"
          end

          Template.new(self, name, filename, element["href"])
        end
      end
    end

    private

    def current_design_id
      request("/site/blogs/#{@blog_id}/design") do |response|
        response.
        doc.
        css(".design-current .design-actions a").find do |a|
          %r{/([0-9a-f]+)/templates$} === a["href"]
        end and $1
      end
    end
  end
end
