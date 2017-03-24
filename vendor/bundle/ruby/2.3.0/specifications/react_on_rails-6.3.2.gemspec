# -*- encoding: utf-8 -*-
# stub: react_on_rails 6.3.2 ruby lib

Gem::Specification.new do |s|
  s.name = "react_on_rails".freeze
  s.version = "6.3.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Justin Gordon".freeze]
  s.bindir = "exe".freeze
  s.date = "2016-12-09"
  s.description = "See README.md".freeze
  s.email = ["justin@shakacode.com".freeze]
  s.homepage = "https://github.com/shakacode/react_on_rails".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "2.6.10".freeze
  s.summary = "Rails with react server rendering with webpack.".freeze

  s.installed_by_version = "2.6.10" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<connection_pool>.freeze, [">= 0"])
      s.add_runtime_dependency(%q<execjs>.freeze, ["~> 2.5"])
      s.add_runtime_dependency(%q<rainbow>.freeze, ["~> 2.1"])
      s.add_runtime_dependency(%q<rails>.freeze, [">= 3.2"])
      s.add_runtime_dependency(%q<foreman>.freeze, [">= 0"])
      s.add_runtime_dependency(%q<addressable>.freeze, [">= 0"])
      s.add_development_dependency(%q<bundler>.freeze, ["~> 1.10"])
      s.add_development_dependency(%q<rake>.freeze, ["~> 10.0"])
      s.add_development_dependency(%q<rspec>.freeze, [">= 0"])
      s.add_development_dependency(%q<coveralls>.freeze, [">= 0"])
      s.add_development_dependency(%q<generator_spec>.freeze, [">= 0"])
      s.add_development_dependency(%q<pry>.freeze, [">= 0"])
      s.add_development_dependency(%q<pry-byebug>.freeze, [">= 0"])
      s.add_development_dependency(%q<pry-stack_explorer>.freeze, [">= 0"])
      s.add_development_dependency(%q<pry-doc>.freeze, [">= 0"])
      s.add_development_dependency(%q<pry-state>.freeze, [">= 0"])
      s.add_development_dependency(%q<pry-toys>.freeze, [">= 0"])
      s.add_development_dependency(%q<pry-rescue>.freeze, [">= 0"])
      s.add_development_dependency(%q<binding_of_caller>.freeze, [">= 0"])
      s.add_development_dependency(%q<awesome_print>.freeze, [">= 0"])
      s.add_development_dependency(%q<gem-release>.freeze, [">= 0"])
    else
      s.add_dependency(%q<connection_pool>.freeze, [">= 0"])
      s.add_dependency(%q<execjs>.freeze, ["~> 2.5"])
      s.add_dependency(%q<rainbow>.freeze, ["~> 2.1"])
      s.add_dependency(%q<rails>.freeze, [">= 3.2"])
      s.add_dependency(%q<foreman>.freeze, [">= 0"])
      s.add_dependency(%q<addressable>.freeze, [">= 0"])
      s.add_dependency(%q<bundler>.freeze, ["~> 1.10"])
      s.add_dependency(%q<rake>.freeze, ["~> 10.0"])
      s.add_dependency(%q<rspec>.freeze, [">= 0"])
      s.add_dependency(%q<coveralls>.freeze, [">= 0"])
      s.add_dependency(%q<generator_spec>.freeze, [">= 0"])
      s.add_dependency(%q<pry>.freeze, [">= 0"])
      s.add_dependency(%q<pry-byebug>.freeze, [">= 0"])
      s.add_dependency(%q<pry-stack_explorer>.freeze, [">= 0"])
      s.add_dependency(%q<pry-doc>.freeze, [">= 0"])
      s.add_dependency(%q<pry-state>.freeze, [">= 0"])
      s.add_dependency(%q<pry-toys>.freeze, [">= 0"])
      s.add_dependency(%q<pry-rescue>.freeze, [">= 0"])
      s.add_dependency(%q<binding_of_caller>.freeze, [">= 0"])
      s.add_dependency(%q<awesome_print>.freeze, [">= 0"])
      s.add_dependency(%q<gem-release>.freeze, [">= 0"])
    end
  else
    s.add_dependency(%q<connection_pool>.freeze, [">= 0"])
    s.add_dependency(%q<execjs>.freeze, ["~> 2.5"])
    s.add_dependency(%q<rainbow>.freeze, ["~> 2.1"])
    s.add_dependency(%q<rails>.freeze, [">= 3.2"])
    s.add_dependency(%q<foreman>.freeze, [">= 0"])
    s.add_dependency(%q<addressable>.freeze, [">= 0"])
    s.add_dependency(%q<bundler>.freeze, ["~> 1.10"])
    s.add_dependency(%q<rake>.freeze, ["~> 10.0"])
    s.add_dependency(%q<rspec>.freeze, [">= 0"])
    s.add_dependency(%q<coveralls>.freeze, [">= 0"])
    s.add_dependency(%q<generator_spec>.freeze, [">= 0"])
    s.add_dependency(%q<pry>.freeze, [">= 0"])
    s.add_dependency(%q<pry-byebug>.freeze, [">= 0"])
    s.add_dependency(%q<pry-stack_explorer>.freeze, [">= 0"])
    s.add_dependency(%q<pry-doc>.freeze, [">= 0"])
    s.add_dependency(%q<pry-state>.freeze, [">= 0"])
    s.add_dependency(%q<pry-toys>.freeze, [">= 0"])
    s.add_dependency(%q<pry-rescue>.freeze, [">= 0"])
    s.add_dependency(%q<binding_of_caller>.freeze, [">= 0"])
    s.add_dependency(%q<awesome_print>.freeze, [">= 0"])
    s.add_dependency(%q<gem-release>.freeze, [">= 0"])
  end
end
