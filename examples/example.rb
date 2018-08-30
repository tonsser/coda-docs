require "coda_docs"

client = CodaDocs.client(api_token: ENV.fetch("CODA_API_TOKEN"))

doc = client.docs.all.detect { |doc| doc.name.include? "Trial" }

pp doc.controls.all
