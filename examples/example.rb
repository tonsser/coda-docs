require "coda_docs"

client = CodaDocs.client(api_token: ENV.fetch("CODA_API_TOKEN"))

page = client.docs.all(limit: 2)

while page.next_page?
  pp page.size
  page = page.next_page
end
