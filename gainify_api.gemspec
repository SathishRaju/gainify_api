# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "gainify_api/version"

Gem::Specification.new do |s|
  s.name = %q{gainify_api}
  s.version = GainifyAPI::VERSION
  s.author = "Gainify"

  s.summary = %q{The Gainify API gem is a lightweight gem for accessing the Gainify admin REST web services}
  s.description = %q{The Gainify API gem allows Ruby developers to programmatically access the admin section of Gainify stores. The API is implemented as JSON or XML over HTTP using all four verbs (GET/POST/PUT/DELETE). Each resource, like Order, Product, or Collection, has its own URL and is manipulated in isolation.}
  s.email = %q{developers@jadedpixel.com}
  s.homepage = %q{http://www.gainify.com/partners/apps}

  s.extra_rdoc_files = [
    "LICENSE",
    "README.rdoc"
  ]
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }

  s.rdoc_options = ["--charset=UTF-8"]
  s.summary = %q{GainifyAPI is a lightweight gem for accessing the Gainify admin REST web services}
  s.license = 'MIT'

  s.add_dependency("activeresource", [">= 3.0.0"])
  s.add_dependency("thor", ["~> 0.18.1"])

  if s.respond_to?(:add_development_dependency)
    s.add_development_dependency("mocha", ">= 0.9.8")
    s.add_development_dependency("fakeweb")
    s.add_development_dependency("minitest", "~> 4.0")
    s.add_development_dependency("rake")
  else
    s.add_dependency("mocha", ">= 0.9.8")
    s.add_dependency("fakeweb")
    s.add_dependency("minitest", "~> 4.0")
    s.add_dependency("rake")
  end
end
