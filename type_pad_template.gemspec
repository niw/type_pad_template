# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "type_pad_template/version"

Gem::Specification.new do |s|
  s.name        = "type_pad_template"
  s.version     = TypePadTemplate::VERSION
  s.authors     = ["Yoshimasa Niwa"]
  s.email       = ["niw@niw.at"]
  s.homepage    = "http://niw.at/"
  s.summary     =
  s.description = ""

  s.rubyforge_project = "type_pad_template"

  s.test_files       = `git ls-files -- test/*`.split("\n")
  s.extra_rdoc_files = `git ls-files -- README*`.split("\n")
  s.files            = `git ls-files -- {bin,lib}/*`.split("\n") +
                       s.test_files +
                       s.extra_rdoc_files

  s.require_path = "lib"
  s.bindir       = "bin"
  s.executables  = `git ls-files -- bin/*`.split("\n").map{|path| File.basename(path)}

  s.add_runtime_dependency("typhoeus")
  s.add_runtime_dependency("nokogiri")
  s.add_runtime_dependency("thor")
  s.add_runtime_dependency("highline")

  s.add_development_dependency("bundler")
  s.add_development_dependency("rake")
end
