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

      def http_get(url)
        response = Http.get(
          "#{API_URL}#{url}",
          headers: { "Authorization" => "Bearer #{api_token}" },
        )
        raise "Request failed" unless response.status == 200
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
        parse(http_get("/docs"), with: ResponseParsers::List.new)
      end

      def get(id)
        parse(http_get("/docs/#{id}"), with: ResponseParsers::Resource.new)
      end

      # TODO: create
    end

    class Sections < CodaHttpClient
      extend TakesMacro
      takes [:api_token!, :doc!]

      def all
        parse(
          http_get("/docs/#{doc.id}/sections"),
          with: ResponseParsers::List.new,
        )
      end

      def get(id)
        parse(
          http_get("/docs/#{doc.id}/sections/#{id}"),
          with: ResponseParsers::Resource.new,
        )
      end
    end

    class Folders < CodaHttpClient
      extend TakesMacro
      takes [:api_token!, :doc!]

      def all
        parse(
          http_get("/docs/#{doc.id}/folders"),
          with: ResponseParsers::List.new,
        )
      end

      def get(id)
        parse(
          http_get("/docs/#{doc.id}/folders/#{id}"),
          with: ResponseParsers::Resource.new,
        )
      end
    end

    class Tables < CodaHttpClient
      extend TakesMacro
      takes [:api_token!, :doc!]

      def all
        parse(
          http_get("/docs/#{doc.id}/tables"),
          with: ResponseParsers::List.new,
        )
      end

      def get(id)
        parse(
          http_get("/docs/#{doc.id}/tables/#{id}"),
          with: ResponseParsers::Resource.new,
        )
      end
    end

    class Columns < CodaHttpClient
      extend TakesMacro
      takes [:api_token!, :doc!, :table!]

      def all
        parse(
          http_get("/docs/#{doc.id}/tables/#{table.id}/columns"),
          with: ResponseParsers::List.new,
        )
      end

      def get(id)
        parse(
          http_get("/docs/#{doc.id}/tables/#{table.id}/columns/#{id}"),
          with: ResponseParsers::Resource.new,
        )
      end
    end

    class Rows < CodaHttpClient
      extend TakesMacro
      takes [:api_token!, :doc!, :table!]

      def all
        parse(
          http_get("/docs/#{doc.id}/tables/#{table.id}/rows"),
          with: ResponseParsers::List.new,
        )
      end

      def get(id)
        parse(
          http_get("/docs/#{doc.id}/tables/#{table.id}/rows/#{id}"),
          with: ResponseParsers::Resource.new,
        )
      end

      # TODO: insert/upsert
      # TODO: update
      # TODO: delete
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
  end
end
