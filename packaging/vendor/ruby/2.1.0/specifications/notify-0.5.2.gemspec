# -*- encoding: utf-8 -*-
# stub: notify 0.5.2 ruby lib

Gem::Specification.new do |s|
  s.name = "notify"
  s.version = "0.5.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["jugyo"]
  s.date = "2013-06-13"
  s.description = "Desctop notify for many platform"
  s.email = ["jugyo.org@gmail.com"]
  s.executables = ["notify"]
  s.files = ["bin/notify"]
  s.homepage = "http://github.com/jugyo/notify"
  s.licenses = ["MIT"]
  s.rubygems_version = "2.4.3"
  s.summary = "Desctop notify for many platform"

  s.installed_by_version = "2.4.3" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<bundler>, ["~> 1.3"])
      s.add_development_dependency(%q<rake>, [">= 0"])
    else
      s.add_dependency(%q<bundler>, ["~> 1.3"])
      s.add_dependency(%q<rake>, [">= 0"])
    end
  else
    s.add_dependency(%q<bundler>, ["~> 1.3"])
    s.add_dependency(%q<rake>, [">= 0"])
  end
end
