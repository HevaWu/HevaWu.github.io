# -*- encoding: utf-8 -*-
# stub: jekyll-assets 2.3.2 ruby lib

Gem::Specification.new do |s|
  s.name = "jekyll-assets".freeze
  s.version = "2.3.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Jordon Bedwell".freeze, "Aleksey V Zapparov".freeze, "Zachary Bush".freeze]
  s.date = "2017-06-21"
  s.description = "    A Jekyll plugin, that allows you to write javascript/css assets in\n    other languages such as CoffeeScript, Sass, Less and ERB, concatenate\n    them, respecting dependencies, minify and many more.\n".freeze
  s.email = ["jordon@envygeeks.io".freeze, "ixti@member.fsf.org".freeze, "zach@zmbush.com".freeze]
  s.homepage = "http://github.com/jekyll/jekyll-assets/".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.0.6".freeze
  s.summary = "Assets for Jekyll".freeze

  s.installed_by_version = "3.0.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rack>.freeze, ["~> 1.6"])
      s.add_runtime_dependency(%q<sprockets>.freeze, ["~> 3.3", "< 3.8"])
      s.add_runtime_dependency(%q<fastimage>.freeze, [">= 1.8", "~> 2.0"])
      s.add_runtime_dependency(%q<jekyll>.freeze, [">= 3.0", "~> 3.1"])
      s.add_runtime_dependency(%q<pathutil>.freeze, [">= 0.8"])
      s.add_runtime_dependency(%q<extras>.freeze, ["~> 0.2"])
      s.add_runtime_dependency(%q<concurrent-ruby>.freeze, ["~> 1.0"])
      s.add_development_dependency(%q<nokogiri>.freeze, ["~> 1.6"])
      s.add_development_dependency(%q<luna-rspec-formatters>.freeze, ["~> 3.5"])
      s.add_development_dependency(%q<rspec>.freeze, ["~> 3.4"])
    else
      s.add_dependency(%q<rack>.freeze, ["~> 1.6"])
      s.add_dependency(%q<sprockets>.freeze, ["~> 3.3", "< 3.8"])
      s.add_dependency(%q<fastimage>.freeze, [">= 1.8", "~> 2.0"])
      s.add_dependency(%q<jekyll>.freeze, [">= 3.0", "~> 3.1"])
      s.add_dependency(%q<pathutil>.freeze, [">= 0.8"])
      s.add_dependency(%q<extras>.freeze, ["~> 0.2"])
      s.add_dependency(%q<concurrent-ruby>.freeze, ["~> 1.0"])
      s.add_dependency(%q<nokogiri>.freeze, ["~> 1.6"])
      s.add_dependency(%q<luna-rspec-formatters>.freeze, ["~> 3.5"])
      s.add_dependency(%q<rspec>.freeze, ["~> 3.4"])
    end
  else
    s.add_dependency(%q<rack>.freeze, ["~> 1.6"])
    s.add_dependency(%q<sprockets>.freeze, ["~> 3.3", "< 3.8"])
    s.add_dependency(%q<fastimage>.freeze, [">= 1.8", "~> 2.0"])
    s.add_dependency(%q<jekyll>.freeze, [">= 3.0", "~> 3.1"])
    s.add_dependency(%q<pathutil>.freeze, [">= 0.8"])
    s.add_dependency(%q<extras>.freeze, ["~> 0.2"])
    s.add_dependency(%q<concurrent-ruby>.freeze, ["~> 1.0"])
    s.add_dependency(%q<nokogiri>.freeze, ["~> 1.6"])
    s.add_dependency(%q<luna-rspec-formatters>.freeze, ["~> 3.5"])
    s.add_dependency(%q<rspec>.freeze, ["~> 3.4"])
  end
end
