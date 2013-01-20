Gem::Specification.new do |s|
  s.name        = 'barebone-fsm'
  s.version     = '0.0.2.1'
  s.date        = '2013-01-20'
  s.summary     = "A barebone finite state machine(FSM)."
  s.description = "A barebone implementation of the finite state machine keeping simplicity in mind."
  s.license     = 'MIT'
  s.has_rdoc    = true
  s.extra_rdoc_files = ['README.rdoc']
  s.authors     = ["Md. Imrul Hassan"]
  s.email       = 'mihassan@gmail.com'
  s.files       =  Dir.glob("{example,spec,lib}/**/*") + %w(README.rdoc MIT-LICENSE)
  s.homepage    = 'https://github.com/mihassan/barebone-fsm/'
end