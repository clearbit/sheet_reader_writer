require 'google/apis/sheets_v4'
require 'googleauth'
require 'sheet_reader_writer/errors'

class SheetReaderWriter
  REQUIRED_ENV_VARS = %w[GOOGLE_CLIENT_EMAIL
                         GOOGLE_ACCOUNT_TYPE
                         GOOGLE_PRIVATE_KEY]

  # Creates a new instance to interact with Google Sheets
  #
  # Example:
  #   >> SheetReaderWriter.new("1ukhJwquqRTgfX-G-nxV6AsAH726TOsKQpPJfpqNjWGg").read("Sheet 1")
  #   => [{"foo"=>"hey", "bar"=>"ho"},
  #       {"foo"=>"let's ", "bar"=>"go"}]
  #
  # Arguments:
  #   sheet_id: (String) The google sheet identifier.
  #
  def initialize(sheet_id, write_permission: true)
    raise MissingEnvVars unless required_env_vars?
    ensure_valid_key_format

    with_exceptions do
      sheets = Google::Apis::SheetsV4::SheetsService.new

      scopes = if write_permission
        ['https://www.googleapis.com/auth/spreadsheets']
      else
        ['https://www.googleapis.com/auth/spreadsheets.readonly']
      end

      sheets.authorization = Google::Auth.get_application_default(scopes)

      @sheet_service = sheets
      @sheet_id = sheet_id
    end
  end

  # Fetches the content of a google spreadsheet
  #
  # Example:
  #   >> sheet_reader_writer.read("Sheet 1")
  #   => [{"foo"=>"hey", "bar"=>"ho"},
  #       {"foo"=>"let's ", "bar"=>"go"}]
  #
  # Arguments:
  #   sheet_name: (String) The sheet name, by default it's the first one
  #
  def read(sheet_name = "")
    with_exceptions do
      raw_values = @sheet_service.get_spreadsheet_values(@sheet_id, "#{sheet_name}!A:ZZ").values
      rows_as_hashes(raw_values)
    end
  end

  # Writes the specified content to a google spreadsheet
  #
  # Example:
  #   >> sheet_reader_writer.write [
  #        ["foo",   "bar"],
  #        ["hey",    "ho"],
  #        ["let's",   nil],
  #        [nil,      "go"]
  #      ]
  #
  # Arguments:
  #   values: (Array of strings) The values to update where the first row
  #represent the column names or keys returned by #read
  #
  def write(values, sheet_name = "")
    value_range_object = {
      major_dimension: "ROWS",
      values: values
    }

    with_exceptions do
      @sheet_service.update_spreadsheet_value(@sheet_id, "#{sheet_name}!A:ZZ", value_range_object, value_input_option: 'USER_ENTERED')
    end
  end

  # Clears a google spreadsheet
  #
  # Example:
  #   >> sheet_reader_writer.clear
  #
  def clear(sheet_name = "")
    with_exceptions do
      @sheet_service.clear_values(@sheet_id, "#{sheet_name}!A:ZZ")
    end
  end

  private

  def with_exceptions
    begin
      yield
    rescue Google::Apis::ClientError => e
      raise BadSheetId if e.message =~ /notFound/
      raise Unauthorized if e.message =~ /forbidden/
    rescue
      raise Error
    end
  end

  def ensure_valid_key_format
    ENV['GOOGLE_PRIVATE_KEY'] = ENV['GOOGLE_PRIVATE_KEY'].gsub(/\\n/, "\n")
  end

  def rows_as_hashes(rows)
    keys, *rest = rows

    rest.map do |row|
      Hash[keys.zip(convery_empty_cells_to_nil(row))]
    end
  end

  def convery_empty_cells_to_nil(row)
    row.map do |cell|
      if cell.strip == ""
        nil
      else
        cell
      end
    end
  end

  def required_env_vars?
    REQUIRED_ENV_VARS.all? do |e|
      ENV.has_key?(e) &&
      ENV.fetch(e) &&
      ENV.fetch(e).strip != ""
    end
  end
end
