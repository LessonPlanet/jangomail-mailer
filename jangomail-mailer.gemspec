# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "jangomail-mailer/version"

Gem::Specification.new do |s|
  s.name        = "jangomail-mailer"
  s.version     = Jangomail::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Jason Rust"]
  s.email       = ["jason@rustedcode.com"]
  s.homepage    = "http://github.com/jrust/jangomail-mailer"
  s.summary     = %q{JangoMail mailer}
  s.description = %q{Implements the JangoMail Transactional API as a custom mailer class.}

  s.add_dependency "mail"
  s.add_development_dependency "rspec", "~> 2.5.0"
  s.add_development_dependency "fakeweb", "~> 1.3.0"

  s.rubyforge_project = "jangomail-mailer"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
