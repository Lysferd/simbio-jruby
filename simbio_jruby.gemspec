Gem::Specification.new do |s|
  s.name        = 'simbio_jruby'
  s.version     = '1.0.0'
  s.date        = Time::now.strftime('%Y-%m-%d')
  s.summary     = 'A simple packaging of SimBio for JRuby'
  s.description = 'A simple packaging of the biological simulator SimBio for JRuby.'
  s.authors     = ['Fábio Moritz de Almeida']
  s.email       = 'phabio_almeida@hotmail.com'
  s.files       = Dir['lib/*.rb'] + Dir['lib/*/*.rb'] + Dir['tools/*.rb']
  s.homepage    = 'https://github.com/Lysferd/simbio-jruby'
  s.license     = 'GLPv3'
end