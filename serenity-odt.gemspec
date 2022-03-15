lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'serenity/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "odt-serenity"
  s.version     = Serenity::VERSION
  s.authors     = "kremso"
  s.email       = ""
  s.homepage    = "https://github.com/mr-dxdy/serenity"
  s.summary     = "Fork of project serenity-odt. Parse ODT file and substitutes placeholders like ERb."
  s.description = "Embedded ruby for OpenOffice/LibreOffice Text Document (.odt) files. You provide an .odt template with ruby code in a special markup and the data, and Serenity generates the document. Very similar to .erb files."

  s.files = Dir["{lib}/**/*"] + ["LICENSE", "Rakefile", "README.md"]
  s.add_dependency "rubyzip", '>=1.2.1'
  s.add_dependency "nokogiri", '>=1.0'
  s.add_development_dependency 'rspec', '>= 1.2.9'
  s.add_development_dependency 'byebug'
end
