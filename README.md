# Sheet Reader Writer

A gem to read and write to [Google Sheets](https://docs.google.com/spreadsheets)

## Usage

* First you'll need to [create a service account](https://developers.google.com/api-client-library/ruby/auth/service-accounts#creatinganaccount)
* Remember to add the Google Sheet API and enable it for your service account.
* From the downloaded `json` file create 3 environment variables:
```bash
export GOOGLE_CLIENT_EMAIL="exampleserviceaccount@example.iam.gserviceaccount.com"
export GOOGLE_ACCOUNT_TYPE="service_account"
export GOOGLE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nMIIEvQIBDDANBgkqhkiG9w0BAQEFASSCBKcwggSjAgEAAoIBAQCtrSUtw2l+7RZb\nxYacxY/vdZhrmTWFeOGOgaeO04FBsa/xu+0/rrkqNDWUQwhY0KSyYM6LkylKK8bg\nPbzv3edlCGAaz9C+ecrXlpdLp1gJuy0Oyjk+ktF6geT717TsIQEP7rWN6EmuDnJY\nwZb66GE2TeQ/HSE9SZPIikrmTICVx2195mPtym5RSCl0BcannezPoJM1zaNLTJAW\nFTodTWW3eBvYoYK2ZOpixPXLhGuHmgG3PxZT5VQqd0JAJmE/76+6MAxtLEPSH+ys\nsCY8fgS8oFzPwqml01SjueFKkmfe+VarZ9DEZC50jzClat2jbQYo7i1vS+eYXmGD\nxShp7ZerAgMBAAECggEAeWdzec4DzMoGuxgUxToFJ6rYZT6v/yFE6s0PR/Ppgvam\nuyBW9BE7NplQateA2jTfLCInv8GbN1Hqr434qORBgIqeQ5/Jl5yjgpiuIiBUlljV\nYmVSJr+S10Q9wR5ERlu71ltTZmNePeGzZP/Ofo46hi9kwgmm1qS8PY8OVHZd3FRo\nfmm+Iv5Kfqc9aPi+GIUKzaOXZMwq9Ye9O/zKEEX+7olZDfjGmEuZlfeLcVHsPKx7\nMWutSTtBqf+jvv+Opqvb0/LNrRFxyOQDW1xNdDwYrym0hUJaflAQmszo5ZhSQcah\nB1jEauTxr6xyMVdqZNdg8vTKVJP+8uc/V75B3Mz4gQKBgQDgp82GR9W1NX+pOAR/\noaKJWNgpsgyB++kljZMLoMYYxhu6aIaZsOrzh2peSKeVTntlRoqmPiJLsD6Kf64I\ny8jpP2TwjjUb4MuNUIgmlcp25zpq7r7suZemqkXheLlJgxk8HSstScyY6zqwKapI\nbf1rhuwTMOMSHjlXp/lbpdS0ewKBgQDF6HsC58ItJ+7hG5UNnaWJlPei+uTq2cGA\n6Mpj4UUH2WAX5ySQMAuOX7Hvuwaxnjb0Epu5N2YfAF9PcQ555wza6SGxOq55Fy8n\nmD2s/VovSa74qFA00P5rDucdbCOB8twWRnnoR+l6u5DjHSBXW9PBHD4n3vmRMn5Y\nbqnh8Fa6kQKBgEtNE5+xzlkp8Ht48lERjZh59iKrsnOTS4ex15rrLds59CtcQ9ma\nKnasaiPmOH3cS5IbvfeRFg/GqH/l4iDCpbpA7IWRNQ3+IFxipPBB/xYx1SvokIhq\ngQF1S20S+RBB6CB1KnbIqNKM7iQEIzaZ33q+Q7z/Au2cwd22yOdGQ3CnAoGBAKh+\nz0Rg9wQlDI9hQVzvTEG/r7p167I7pTDQgYfaAkC1hMe1Bn8wOJaFyOO3EvLkJhtV\nQHnHvc1FLuBe/BkzatFyTTosIOF9qKsIRfJjXYYHMM4J1wewq/uQG5sEN5LqpxDb\n/eySVSkmSivi32chCj9OgWjGwSoqmEFILqDrU5vRAoGAY7Xw22waPoYmi4Cyh8QG\nrGSHnzpZJBj4UUsREkWSta9R6yYxAh5IOEn3Z3sKymYfrpCfi7FxOQF5xwZEgiwA\nxImI/CLblamTWuF+jdj2+0eXaq20IWdOaAN27cPBxvJUSJ15u1Em+/AJzKbBBTLL\nn92P3S0+HZHzK+QdDOgCfsA=\n-----END PRIVATE KEY-----"
```
* Give the desired access to the Google Sheet using the service account email. In our example that's `exampleserviceaccount@example.iam.gserviceaccount.com
`.
Now you are ready to consume the spreadsheet:

```ruby
require 'sheet_reader_writer'
result = SheetReaderWriterWriter.read('1Q2NdvsSECbDrdOf9-C1WhzHq__3jWW3lQWDDB0mJbd9')
puts result
```
which returns an array of hashes, where each hash represents a row keyed by the column names found in the first row of the spreadsheet:

```
[{"foo"=>"hey", "bar"=>"ho"}, {"foo"=>"let's", "bar"=>nil}, {"foo"=>nil, "bar"=>"go"}]
```

This would be mapped to a spreadsheet with this structure:

| foo | bar |
| --- | --- |
| hey | ho  |
|let's|     |
|     | go  |

Notice that empty lines are mapped to `nil`

By default `sheet_reader_writer` chooses the first sheet of the document. You can specify another sheet by it's name with:

```ruby
SheetReaderWriter.read('1Q2NdvsSECbDrdOf9-C1WhzHq__3jWW3lQWDDB0mJbd9', "Some other sheet")
```

## Error handling

A non existent sheet id will raise a `SheetReaderWriter::BadSheetId`.

An unauthorized sheet will raise a `SheetReaderWriter::Unauthorized`.

Any other error will be wrapped in a generic `SheetReaderWriter::Error`.

All errors inherit from `SheetReaderWriter::Error`.

## License

`sheet_reader_writer` is copyright © 2016 Clearbit. It is free software, and may
be redistributed under the terms specified in the [`LICENSE`] file.

[`LICENSE`]: /LICENSE
