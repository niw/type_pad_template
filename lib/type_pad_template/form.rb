module TypePadTemplate
  class Form
    def initialize(form_element)
      @form_element = form_element
      @values = default_values
    end

    def [](key)
      @values[key.to_sym]
    end

    def []=(key, value)
      @values[key.to_sym] = value
    end

    def to_hash
      @values.dup
    end

    def method
      @form_element["method"].downcase.to_sym rescue :get
    end

    def url
      @form_element["action"]
    end

    private

    def default_values
      @form_element.search("input[@name!='']").inject({}) do |hash, input|
        hash[input["name"].to_sym] = input["value"] if input["name"]
        hash
      end
    end
  end
end
