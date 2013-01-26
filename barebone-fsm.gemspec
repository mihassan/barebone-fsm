Gem::Specification.new do |spec|
  spec.name        = 'barebone-fsm'
  spec.version     = '0.0.2.1'
  spec.date        = '2013-01-20'
  spec.summary     = "A barebone finite state machine(FSM)."
  spec.description = "A barebone implementation of the finite state machine keeping simplicity in mind."
  spec.license     = 'MIT'
  spec.has_rdoc    = true
  spec.extra_rdoc_files = ['README.rdoc']
  spec.authors     = ["Md. Imrul Hassan"]
  spec.email       = 'mihassan@gmail.com'
  spec.files       =  Dir.glob("{example,spec,lib}/**/*") + %w(README.rdoc MIT-LICENSE)
  spec.homepage    = 'https://github.com/mihassan/barebone-fsm/'
end