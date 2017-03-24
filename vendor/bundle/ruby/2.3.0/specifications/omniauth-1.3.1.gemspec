# -*- encoding: utf-8 -*-
# stub: omniauth 1.3.1 ruby lib

Gem::Specification.new do |s|
  s.name = "omniauth".freeze
  s.version = "1.3.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.3.5".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Michael Bleigh".freeze, "Erik Michaels-Ober".freeze, "Tom Milewski".freeze]
  s.date = "2015-12-20"
  s.description = "A generalized Rack framework for multiple-provider authentication.".freeze
  s.email = ["michael@intridea.com".freeze, "sferik@gmail.com".freeze, "tmilewski@gmail.com".freeze]
  s.homepage = "http://github.com/intridea/omniauth".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "2.6.10".freeze
  s.summary = "A generalized Rack framework for multiple-provider authentication.".freeze

  s.installed_by_version = "2.6.10" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<hashie>.freeze, ["< 4", ">= 1.2"])
      s.add_runtime_dependency(%q<rack>.freeze, ["< 3", ">= 1.0"])
      s.add_development_dependency(%q<bundler>.freeze, ["~> 1.0"])
    else
      s.add_dependency(%q<hashie>.freeze, ["< 4", ">= 1.2"])
      s.add_dependency(%q<rack>.freeze, ["< 3", ">= 1.0"])
      s.add_dependency(%q<bundler>.freeze, ["~> 1.0"])
    end
  else
    s.add_dependency(%q<hashie>.freeze, ["< 4", ">= 1.2"])
    s.add_dependency(%q<rack>.freeze, ["< 3", ">= 1.0"])
    s.add_dependency(%q<bundler>.freeze, ["~> 1.0"])
  end
end
