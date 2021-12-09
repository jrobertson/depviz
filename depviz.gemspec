Gem::Specification.new do |s|
  s.name = 'depviz'
  s.version = '0.5.3'
  s.summary = 'Generates a complete dependency tree from disparate ' + 
      'dependencies to an SVG document.'
  s.authors = ['James Robertson']
  s.files = Dir['lib/depviz.rb']
  s.add_runtime_dependency('pxgraphviz', '~> 0.5', '>=0.5.3')
  s.add_runtime_dependency('dependency_builder', '~> 0.1', '>=0.1.0')
  s.add_runtime_dependency('xml_to_sliml', '~> 0.1', '>=0.1.0')   
  s.signing_key = '../privatekeys/depviz.pem'
  s.cert_chain  = ['gem-public_cert.pem']
  s.license = 'MIT'
  s.email = 'james@jamesrobertson.eu'
  s.homepage = 'https://github.com/jrobertson/depviz'
end
