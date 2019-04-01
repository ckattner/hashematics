# frozen_string_literal: true

require './lib/hashematics/version'

Gem::Specification.new do |s|
  s.name        = 'Hashematics'
  s.version     = Hashematics::VERSION
  s.summary     = 'Configurable Data Shaper'

  s.description = <<-DESCRIPTION
    Hashematics is a configuration-based object graphing tool which can turn a flat, single dimensional dataset into a structure of deeply nested objects.
  DESCRIPTION

  s.authors     = ['Matthew Ruggio']
  s.email       = ['mruggio@bluemarblepayroll.com']
  s.files       = `git ls-files`.split("\n")
  s.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.homepage    = 'https://github.com/bluemarblepayroll/hashematics'
  s.license     = 'MIT'

  s.required_ruby_version = '>= 2.3.8'

  s.add_development_dependency('faker')
  s.add_development_dependency('guard-rspec', '~>4.7')
  s.add_development_dependency('pdf-inspector', '~>1')
  s.add_development_dependency('pry')
  s.add_development_dependency('rspec', '~> 3.8')
  s.add_development_dependency('rubocop', '~>0.63.1')
  s.add_development_dependency('simplecov', '~>0.16.1')
  s.add_development_dependency('simplecov-console', '~>0.4.2')
end
