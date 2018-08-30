require "coda_docs"

pp ->() {
  client = CodaDocs.client(api_token: ENV.fetch("CODA_API_TOKEN"))

  doc = client.docs.all.detect { |doc| doc.name.include? "ruby wrapper test" }

  table = client.tables(doc).all.first

  columns = client.columns(doc, table).all
  raise unless columns.size == 2

  row = client.rows(doc, table).all.last

  client.rows(doc, table).update(
    row.id,
    {
      columns[0].id => "2.1 #{Time.now.to_s}",
      columns[1].id => "2.2 #{Time.now.to_s}",
    },
  )
}.()
