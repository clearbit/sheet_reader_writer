require_relative 'lib/sheet_reader_writer/version'

Gem::Specification.new do |s|
  s.name        = 'sheet_reader_writer'
  s.version     = SheetReaderWriter::VERSION
  s.date        = '2016-11-22'
  s.summary     = "Read and write to google spreadsheets"
  s.description = "A gem to read and write to google spreadsheets"
  s.authors     = ["Clearbit"]
  s.email       = 'daniel@clearbit.com'
  s.files       = `git ls-files -z lib`.split("\x0")
  s.homepage    = 'http://github.com/cleabit/sheet_reader_writer'
  s.license     = 'MIT'
  s.add_runtime_dependency 'googleauth', '~> 0.5'
  s.add_runtime_dependency 'google-api-client', '~> 0.9'
end
