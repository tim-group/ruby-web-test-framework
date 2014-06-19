require 'rake'

hash    = `git rev-parse --short HEAD`.chomp
v_part  = ENV['BUILD_NUMBER'] || "0.pre.#{hash}"
version = "0.1.#{v_part}"

Gem::Specification.new do |s|
  s.name          = 'web-test-framework'
  s.version       = version
  s.date          = Time.now.strftime("%Y-%m-%d")
  s.summary       = "Nagios Support"
  s.description   = "Support testing of Ruby based Nagios checks on the command line against a Webrick test server."
  s.authors       = ["Richard Pearce", "Mehul Shah"]
  s.email         = 'mehul.shah@timgroup.com'
  s.homepage      = "https://github.com/youdevise/ruby-web-test-framework"
  s.license       = "GNU"
  s.files         = "lib/web-test-framework.rb"
  s.require_paths = ["lib"]
end

