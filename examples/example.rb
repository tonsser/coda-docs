require "coda_docs"

pp ->() {
  client = CodaDocs.client(api_token: ENV.fetch("CODA_API_TOKEN"))

  doc = client.docs.all.detect { |doc| doc.name.include? "Trials & Events" }

  table = client.tables(doc).all.first

  row = client.rows(doc, table).all.first

  client.rows(doc, table).get(row.id).parent
}.()
