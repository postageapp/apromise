Gem::Specification.new do |spec|
  spec.name = 'apromise'
  spec.version = File.readlines(File.expand_path('VERSION', __dir__)).first.chomp
  spec.authors = [ 'Scott Tadman' ]
  spec.email = %w[ tadman@postageapp.com ]

  spec.summary = %q{A Promise for Async}
  spec.description = %q{Promise implementation for Ruby Async}
  spec.homepage = 'https://github.com/postageapp/apromise'
  spec.license = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.5.0')

  spec.metadata['allowed_push_host'] = 'https://rubygems.org/'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/postageapp/apromise'
  spec.metadata['changelog_uri'] = 'https://github.com/postageapp/apromise'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      f.match(%r{(?:\A(?:(?:bin|test|spec|features)/|\.))|(?:\.(?:md|txt)\z)})
    end
  end

  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = %w[ lib ]

  spec.add_dependency 'async'
end
