require "type_pad_template/version"
require "nokogiri"
require "typhoeus"
require "uri"
require "forwardable"

module TypePadTemplate
  autoload :Form, "type_pad_template/form"
  autoload :Request, "type_pad_template/request"
  autoload :Response, "type_pad_template/response"
  autoload :Account, "type_pad_template/account"
  autoload :Blog, "type_pad_template/blog"
  autoload :Template, "type_pad_template/template"
end
