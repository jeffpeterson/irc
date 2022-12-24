Gem::Specification.new do |spec|
  spec.name          = 'irc'
  spec.version       = '0.0.5'
  spec.licenses      = ['MIT']
  spec.files          = ['README.markdown', 'lib/irc.rb'] + Dir['lib/**/*.rb']
  spec.platform      = Gem::Platform::RUBY
  spec.require_paths = %w[lib]
  spec.summary       = "a simple ruby irc (bot) framework"
  spec.author        = "Jeff Peterson"
  spec.email         = "jeff@petersonj.com"
  spec.homepage      = "http://github.com/jeffpeterson/irc"
  spec.description   = "a simple ruby irc (bot) framework"
end
