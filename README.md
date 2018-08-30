# `CodaDocs`

This gem aims to be a complete wrapper around [Coda's REST API](https://coda.io/developers/apis/v1beta1). It is currently work in progress and everything is subject to change.

## Installation

The gem is not published on [rubygems.org](rubygems.org) yet so you have to install it directly from GitHub:

```ruby
gem "coda-docs", git: "https://github.com/tonsser/coda-docs.git"
```

Remember to run `bundle install`.

## Whats missing?

- [Query params for `columns.all`](https://coda.io/developers/apis/v1beta1#operation/listRows)
- Error handling

## Usage

### Setup

```ruby
client = CodaDocs.client(api_token: some_token)
```

### Docs

```ruby
# Get all the documents
client.docs.all

# Get a single doc
client.docs.get(doc_id)

# Create a doc
client.docs.create(title: "Doc title")
```

### Sections

```ruby
# Get all sections
client.docs.all[0].sections.all

# Get a single section
client.docs.all[0].sections.get(section_id)
```

### Folders

```ruby
# Get all folders
client.docs.all[0].folders.all

# Get a single folder
client.docs.all[0].folders.get(folder_id)
```

### Tables

```ruby
# Get all tables
client.docs.all[0].tables.all

# Get a single table
client.docs.all[0].tables.get(table_id)
```

#### Columns

```ruby
# Get all columns
client.docs.all[0].tables.all[0].columns.all

# Get a single column
client.docs.all[0].tables.all[0].columns.get(column_id)
```

#### Rows

```ruby
# Get all rows
client.docs.all[0].tables.all[0].rows.all

# Get a single row
client.docs.all[0].tables.all[0].rows.get(row_id)

# Insert row
doc = client.docs.all[0]
table = doc.tables.alll[0]
columns = table.columns.all

table.rows.insert(
  [
    {
      columns[0] => "value",
      columns[1] => "other value",
    }
  ]
)

# Update row
doc = client.docs.all[0]
table = doc.tables.alll[0]
columns = table.columns.all

table.rows.update(
  row_id,
  {
    columns[0] => "value",
    columns[1] => "other value",
  }
)

# Delete row
client.docs.all[0].tables.all[0].rows.delete(row_id)
```

### Formulas

```ruby
# Get all formulas
client.docs.all[0].formulas.all

# Get a single formula
client.docs.all[0].formulas.get(formula_id)
```

### Control

```ruby
# Get all controls
client.docs.all[0].controls.all

# Get a single control
client.docs.all[0].controls.get(control_id)
```

### User info

```ruby
client.user_info
```

### Resolve browser link

```ruby
client.resolve_browser_link(url)
```

### What methods can I call?

All resources aim have to methods that match the keys in the HTTP responses. For example the JSON for a document looks like so:

```json
{
  "id": "AbCDeFGH",
  "type": "doc",
  "href": "https://coda.io/apis/v1beta1/docs/AbCDeFGH",
  "browserLink": "https://coda.io/d/_dAbCDeFGH",
  "name": "Product Launch Hub",
  "owner": "user@example.com",
  "sourceDoc": {
    "id": "AbCDeFGH",
    "type": "doc",
    "href": "https://coda.io/apis/v1beta1/docs/AbCDeFGH"
  },
  "createdAt": "2018-04-11T00:18:57.946Z",
  "updatedAt": "2018-04-11T00:18:57.946Z"
}
```

So you're able to call all those keys as methods on a doc object:

```ruby
doc = client.docs.all[0]

doc.id
doc.type
doc.href
doc.browser_link
# etc
```

Note that the keys are converted from camelcase to snakecase.

To get the exact JSON for an object you can always call the `json` method.

```ruby
doc = client.docs.all[0]

doc.json
# =>
#  {
#    "id": "AbCDeFGH",
#    "type": "doc",
#    "href": "https://coda.io/apis/v1beta1/docs/AbCDeFGH",
#    "browserLink": "https://coda.io/d/_dAbCDeFGH",
#    etc...
#  }
```

### Pagination

Any object returned from an `all` method is paginated. You can load subsequent pages like so:

```ruby
page = client.docs.all(limit: 2)

while page.next_page?
  page = page.next_page
end
```
