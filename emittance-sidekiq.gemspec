# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'emittance/sidekiq/version'

Gem::Specification.new do |spec|
  spec.name          = 'emittance-sidekiq'
  spec.version       = Emittance::Sidekiq::VERSION
  spec.authors       = ['Tyler Guillen']
  spec.email         = ['tyguillen@gmail.com']

  spec.summary       = 'The "Sidekiq" dispatch strategy for the Emittance gem'
  spec.description   = 'The "Sidekiq" dispatch strategy for the Emittance gem'
  spec.homepage      = 'https://github.com/aastronautss/emittance-sidekiq'
  spec.license       = 'MIT'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'emittance'
  spec.add_dependency 'sidekiq', '~> 5'

  spec.add_development_dependency 'bundler', '>= 1.17'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'simplecov'
end
