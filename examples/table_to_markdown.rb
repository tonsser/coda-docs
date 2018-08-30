require "coda_docs"

client = CodaDocs.client(api_token: ENV.fetch("CODA_API_TOKEN"))

doc = client.docs.all.detect { |doc| doc.name.include? "Hack" }

table = doc.tables.all.detect { |table| table.name.include? "Ideas" }

columns = table.columns.all

puts columns.map(&:name).join(" | ")
puts columns.map { "---" }.join(" | ")

table.rows.all.sort_by(&:index).each do |row|
  puts columns.map { |column| row.values[column.id] }.join(" | ")
end
