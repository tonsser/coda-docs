module CodaDocs
  class Client
    extend TakesMacro
    takes [:api_token!]

    def docs
      Docs.new(api_token: api_token)
    end

    def sections(doc)
      Sections.new(api_token: api_token, doc: doc)
    end

    def folders(doc)
      Folders.new(api_token: api_token, doc: doc)
    end

    def tables(doc)
      Tables.new(api_token: api_token, doc: doc)
    end

    def columns(doc, table)
      Columns.new(api_token: api_token, doc: doc, table: table)
    end

    def rows(doc, table)
      Rows.new(api_token: api_token, doc: doc, table: table)
    end

    class CodaHttpClient
      API_URL = "https://coda.io/apis/v1beta1".freeze

      private

      def coda_api_get(url)
        response = Http.get(
          "#{API_URL}#{url}",
          headers: { "Authorization" => "Bearer #{api_token}" },
        )
        raise "Request failed" unless response.success?
        response
      end

      def coda_api_post(url, payload: "")
        if payload.is_a?(Hash)
          payload = payload.to_json
        end

        response = Http.post(
          "#{API_URL}#{url}",
          payload: payload,
          headers: {
            "Authorization" => "Bearer #{api_token}",
            "Content-Type" => "application/json",
          },
        )
        raise "Request failed" unless response.success?
        response
      end

      def coda_api_put(url, payload: "")
        if payload.is_a?(Hash)
          payload = payload.to_json
        end

        response = Http.put(
          "#{API_URL}#{url}",
          payload: payload,
          headers: {
            "Authorization" => "Bearer #{api_token}",
            "Content-Type" => "application/json",
          },
        )
        raise "Request failed" unless response.success?
        response
      end

      def coda_api_delete(url)
        response = Http.delete(
          "#{API_URL}#{url}",
          headers: { "Authorization" => "Bearer #{api_token}" },
        )
        raise "Request failed" unless response.success?
        response
      end

      def parse(response, with:)
        with.parse(response.json)
      end
    end

    class Docs < CodaHttpClient
      extend TakesMacro
      takes [:api_token!]

      def all
        parse(coda_api_get("/docs"), with: ResponseParsers::List.new)
      end

      def get(id)
        parse(coda_api_get("/docs/#{id}"), with: ResponseParsers::Resource.new)
      end

      def create(title:, source_doc_id: nil)
        payload = { title: title }

        if source_doc_id
          payload[:sourceDoc] = source_doc_id
        end

        parse(
          coda_api_post("/docs", payload: payload),
          with: ResponseParsers::Resource.new,
        )
      end
    end

    class Sections < CodaHttpClient
      extend TakesMacro
      takes [:api_token!, :doc!]

      def all
        parse(
          coda_api_get("/docs/#{doc.id}/sections"),
          with: ResponseParsers::List.new,
        )
      end

      def get(id)
        parse(
          coda_api_get("/docs/#{doc.id}/sections/#{id}"),
          with: ResponseParsers::Resource.new,
        )
      end
    end

    class Folders < CodaHttpClient
      extend TakesMacro
      takes [:api_token!, :doc!]

      def all
        parse(
          coda_api_get("/docs/#{doc.id}/folders"),
          with: ResponseParsers::List.new,
        )
      end

      def get(id)
        parse(
          coda_api_get("/docs/#{doc.id}/folders/#{id}"),
          with: ResponseParsers::Resource.new,
        )
      end
    end

    class Tables < CodaHttpClient
      extend TakesMacro
      takes [:api_token!, :doc!]

      def all
        parse(
          coda_api_get("/docs/#{doc.id}/tables"),
          with: ResponseParsers::List.new,
        )
      end

      def get(id)
        parse(
          coda_api_get("/docs/#{doc.id}/tables/#{id}"),
          with: ResponseParsers::Resource.new,
        )
      end
    end

    class Columns < CodaHttpClient
      extend TakesMacro
      takes [:api_token!, :doc!, :table!]

      def all
        parse(
          coda_api_get("/docs/#{doc.id}/tables/#{table.id}/columns"),
          with: ResponseParsers::List.new,
        )
      end

      def get(id)
        parse(
          coda_api_get("/docs/#{doc.id}/tables/#{table.id}/columns/#{id}"),
          with: ResponseParsers::Resource.new,
        )
      end
    end

    class Rows < CodaHttpClient
      extend TakesMacro
      takes [:api_token!, :doc!, :table!]

      def all
        parse(
          coda_api_get("/docs/#{doc.id}/tables/#{table.id}/rows"),
          with: ResponseParsers::List.new,
        )
      end

      def get(id)
        parse(
          coda_api_get("/docs/#{doc.id}/tables/#{table.id}/rows/#{id}"),
          with: ResponseParsers::Resource.new,
        )
      end

      def insert(rows, key_column_ids: nil)
        payload = {
          rows: rows.map do |row|
            {
              cells: row.map do |column_id, value|
                {
                  column: column_id,
                  value: value,
                }
              end
            }
          end,
        }

        if key_column_ids
          payload[:keyColumns] = key_column_ids
        end

        parse(
          coda_api_post(
            "/docs/#{doc.id}/tables/#{table.id}/rows",
            payload: payload,
          ),
          with: ResponseParsers::DontParse.new,
        )
      end

      def update(id, row)
        payload = {
          row: {
            cells: row.map do |column_id, value|
              {
                column: column_id,
                value: value,
              }
            end
          }
        }

        parse(
          coda_api_put(
            "/docs/#{doc.id}/tables/#{table.id}/rows/#{id}",
            payload: payload,
          ),
          with: ResponseParsers::DontParse.new,
        )
      end

      def delete(id)
        parse(
          coda_api_delete(
            "/docs/#{doc.id}/tables/#{table.id}/rows/#{id}",
          ),
          with: ResponseParsers::DontParse.new,
        )
      end
    end
  end

  module ResponseParsers
    class List
      def parse(json)
        resource_parser = ResponseParsers::Resource.new

        json.fetch("items").map do |item|
          resource_parser.parse(item)
        end
      end
    end

    class Resource
      def parse(json)
        type = json.fetch("type")

        case type
        when "doc"
          Resources::Doc.new(json)
        when "section"
          Resources::Section.new(json)
        when "folder"
          Resources::Folder.new(json)
        when "table"
          Resources::Table.new(json)
        when "column"
          Resources::Column.new(json)
        when "row"
          Resources::Row.new(json)
        else
          raise "Unknown type: #{type.inspect}"
        end
      end
    end

    class DontParse
      def parse(json)
        json
      end
    end
  end
end
