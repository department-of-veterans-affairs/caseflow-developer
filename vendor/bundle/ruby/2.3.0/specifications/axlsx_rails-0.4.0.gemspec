# -*- encoding: utf-8 -*-
# stub: axlsx_rails 0.4.0 ruby lib

Gem::Specification.new do |s|
  s.name = "axlsx_rails".freeze
  s.version = "0.4.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Noel Peden".freeze]
  s.date = "2015-07-14"
  s.description = "Axlsx_Rails provides an Axlsx renderer so you can move all your spreadsheet code from your controller into view files. Partials are supported so you can organize any code into reusable chunks (e.g. cover sheets, common styling, etc.) You can use it with acts_as_xlsx, placing the to_xlsx call in a view and adding ':package => xlsx_package' to the parameter list. Now you can keep your controllers thin!".freeze
  s.email = ["noel@peden.biz".freeze]
  s.homepage = "https://github.com/straydogstudio/axlsx_rails".freeze
  s.rubygems_version = "2.6.10".freeze
  s.summary = "A simple rails plugin to provide an xlsx renderer using the axlsx gem.".freeze

  s.installed_by_version = "2.6.10" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rails>.freeze, [">= 3.1"])
      s.add_runtime_dependency(%q<axlsx>.freeze, [">= 2.0.1"])
      s.add_development_dependency(%q<bundler>.freeze, [">= 0"])
      s.add_development_dependency(%q<rake>.freeze, [">= 0"])
      s.add_development_dependency(%q<rspec-rails>.freeze, [">= 0"])
      s.add_development_dependency(%q<guard-rspec>.freeze, [">= 0"])
      s.add_development_dependency(%q<capybara>.freeze, [">= 0"])
      s.add_development_dependency(%q<acts_as_xlsx>.freeze, [">= 0"])
      s.add_development_dependency(%q<roo>.freeze, [">= 0"])
      s.add_development_dependency(%q<rubyzip>.freeze, [">= 0"])
      s.add_development_dependency(%q<sqlite3>.freeze, [">= 0"])
      s.add_development_dependency(%q<growl>.freeze, [">= 0"])
      s.add_development_dependency(%q<rb-fsevent>.freeze, [">= 0"])
      s.add_development_dependency(%q<coveralls>.freeze, [">= 0"])
      s.add_development_dependency(%q<pry>.freeze, [">= 0"])
      s.add_development_dependency(%q<pry-nav>.freeze, [">= 0"])
    else
      s.add_dependency(%q<rails>.freeze, [">= 3.1"])
      s.add_dependency(%q<axlsx>.freeze, [">= 2.0.1"])
      s.add_dependency(%q<bundler>.freeze, [">= 0"])
      s.add_dependency(%q<rake>.freeze, [">= 0"])
      s.add_dependency(%q<rspec-rails>.freeze, [">= 0"])
      s.add_dependency(%q<guard-rspec>.freeze, [">= 0"])
      s.add_dependency(%q<capybara>.freeze, [">= 0"])
      s.add_dependency(%q<acts_as_xlsx>.freeze, [">= 0"])
      s.add_dependency(%q<roo>.freeze, [">= 0"])
      s.add_dependency(%q<rubyzip>.freeze, [">= 0"])
      s.add_dependency(%q<sqlite3>.freeze, [">= 0"])
      s.add_dependency(%q<growl>.freeze, [">= 0"])
      s.add_dependency(%q<rb-fsevent>.freeze, [">= 0"])
      s.add_dependency(%q<coveralls>.freeze, [">= 0"])
      s.add_dependency(%q<pry>.freeze, [">= 0"])
      s.add_dependency(%q<pry-nav>.freeze, [">= 0"])
    end
  else
    s.add_dependency(%q<rails>.freeze, [">= 3.1"])
    s.add_dependency(%q<axlsx>.freeze, [">= 2.0.1"])
    s.add_dependency(%q<bundler>.freeze, [">= 0"])
    s.add_dependency(%q<rake>.freeze, [">= 0"])
    s.add_dependency(%q<rspec-rails>.freeze, [">= 0"])
    s.add_dependency(%q<guard-rspec>.freeze, [">= 0"])
    s.add_dependency(%q<capybara>.freeze, [">= 0"])
    s.add_dependency(%q<acts_as_xlsx>.freeze, [">= 0"])
    s.add_dependency(%q<roo>.freeze, [">= 0"])
    s.add_dependency(%q<rubyzip>.freeze, [">= 0"])
    s.add_dependency(%q<sqlite3>.freeze, [">= 0"])
    s.add_dependency(%q<growl>.freeze, [">= 0"])
    s.add_dependency(%q<rb-fsevent>.freeze, [">= 0"])
    s.add_dependency(%q<coveralls>.freeze, [">= 0"])
    s.add_dependency(%q<pry>.freeze, [">= 0"])
    s.add_dependency(%q<pry-nav>.freeze, [">= 0"])
  end
end
