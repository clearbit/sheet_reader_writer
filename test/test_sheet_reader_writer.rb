require 'minitest/autorun'
require 'sheet_reader_writer'

class SheetReaderWriterTest < Minitest::Test
  def test_missing_env_vars
    ENV.stub :fetch, "" do
      error = assert_raises SheetReaderWriter::MissingEnvVars do
        SheetReaderWriter.new('12345678').read
      end

      assert_match /GOOGLE_PRIVATE_KEY/, error.message
    end
  end

  def test_bad_sheet_id
    assert_raises SheetReaderWriter::BadSheetId do
      SheetReaderWriter.new('12345678').read
    end
  end

  def test_with_unauthorized_sheet
    assert_raises SheetReaderWriter::Unauthorized do
      result = SheetReaderWriter.new('1Q732RcSCYJpWZZtnKx4yXVQTgjSEbilJKznsOp-qlPE').read
    end
  end

  def test_with_sample_sheet
    # Be sure to run the test with the correct env variables, this is an integration test that requires internet
    sr = SheetReaderWriter.new('1bDmIkemWGk2wQXhzyAbtraIxMEETjn7XGgQjbna7SIY')

    sr.clear

    today = Date.today
    values = [
      {"foo"=>"hey", "bar"=>"ho"},
      {"foo"=>"let's"},
      {"bar" =>"go"},
      {"foo"=>"today", "bar"=>today.to_s}
    ]

    sr.write(values)
    result = sr.read
    assert_equal [
      {"foo"=>"hey", "bar"=>"ho"},
      {"foo"=>"let's", "bar" => nil},
      {"foo"=>nil, "bar"=>"go"},
      {"foo"=>"today", "bar"=>today.to_s}
    ], result
  end
end
