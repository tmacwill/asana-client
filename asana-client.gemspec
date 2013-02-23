Gem::Specification.new do |s|
    s.name = 'asana-client'
    s.version = '0.0.1'
    s.date = '2012-04-25'
    s.summary = "Ruby client for Asana's REST API"
    s.description = "Command-line client and library for browsing, creating, and completing Asana tasks."
    s.authors = ["Tommy MacWilliam"]
    s.email = "tmacwilliam@cs.harvard.edu"
    s.files = ["lib/asana-client.rb"]
    s.executables << "asana"
    s.add_dependency "chronic", ">= 0.6.7"
    s.add_dependency "json", ">= 1.6.6"
    s.homepage = "https://github.com/tmacwill/asana-client"
end
