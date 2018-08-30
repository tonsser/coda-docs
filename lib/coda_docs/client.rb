require "cgi"
require "delegate"

module CodaDocs
  class Client
    extend TakesMacro
    takes [:api_token!]

    def docs
      Docs.new(client: self, api_token: api_token)
    end

    def sections(doc)
      Sections.new(client: self, api_token: api_token, doc: doc)
    end

    def folders(doc)
      Folders.new(client: self, api_token: api_token, doc: doc)
    end

    def tables(doc)
      Tables.new(client: self, api_token: api_token, doc: doc)
    end

    def columns(doc, table)
      Columns.new(client: self, api_token: api_token, doc: doc, table: table)
    end

    def rows(doc, table)
      Rows.new(client: self, api_token: api_token, doc: doc, table: table)
    end

    def formulas(doc)
      Formulas.new(client: self, api_token: api_token, doc: doc)
    end

    def controls(doc)
      Controls.new(client: self, api_token: api_token, doc: doc)
    end

    def user_info
      UserInfo.new(api_token: api_token).get
    end

    def resolve_browser_link(link)
      ResolveBrowserLink.new(api_token: api_token).get(link)
    end

    def next_page(doc, link)
      NextPageLink.new(client: self, api_token: api_token, doc: doc).get(link)
    end

    class CodaHttpClient
      extend TakesMacro

      API_URL = "https://coda.io/apis/v1beta1".freeze

      private

      def coda_api_get(url, params: {})
        response = Http.get(
          "#{API_URL}#{url}",
          params: params,
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

      def parse(response, with:, doc:)
        with.parse(json: response.json, client: client, doc: doc)
      end

      def add_pagination_params(params, options)
        if options[:limit]
          params[:limit] = options[:limit]
        end

        if options[:page_token]
          params[:pageToken] = options[:page_token]
        end
      end
    end

    class Docs < CodaHttpClient
      takes [:api_token!, :client!]

      def all(options = {})
        params = {}

        if options[:is_owner]
          params[:isOwner] = options[:is_owner]
        end

        if options[:query]
          params[:query] = options[:query]
        end

        if options[:source_doc_id]
          params[:sourceDoc] = options[:source_doc_id]
        end

        add_pagination_params(params, options)

        parse(
          coda_api_get("/docs", params: params),
          with: ResponseParsers::List.new,
          doc: self,
        )
      end

      def get(id)
        parse(
          coda_api_get("/docs/#{id}"),
          with: ResponseParsers::Resource.new,
          doc: self,
        )
      end

      def create(title:, source_doc_id: nil)
        payload = { title: title }

        if source_doc_id
          payload[:sourceDoc] = source_doc_id
        end

        parse(
          coda_api_post("/docs", payload: payload),
          with: ResponseParsers::Resource.new,
          doc: self,
        )
      end
    end

    class Sections < CodaHttpClient
      extend TakesMacro
      takes [:api_token!, :doc!, :client!]

      def all(options = {})
        params = {}
        add_pagination_params(params, options)
        parse(
          coda_api_get("/docs/#{doc.id}/sections", params: params),
          with: ResponseParsers::List.new,
          doc: doc,
        )
      end

      def get(id)
        parse(
          coda_api_get("/docs/#{doc.id}/sections/#{id}"),
          with: ResponseParsers::Resource.new,
          doc: doc,
        )
      end
    end

    class Folders < CodaHttpClient
      extend TakesMacro
      takes [:api_token!, :doc!, :client!]

      def all(options = {})
        params = {}
        add_pagination_params(params, options)
        parse(
          coda_api_get("/docs/#{doc.id}/folders", params: params),
          with: ResponseParsers::List.new,
          doc: doc,
        )
      end

      def get(id)
        parse(
          coda_api_get("/docs/#{doc.id}/folders/#{id}"),
          with: ResponseParsers::Resource.new,
          doc: doc,
        )
      end
    end

    class Tables < CodaHttpClient
      extend TakesMacro
      takes [:api_token!, :doc!, :client!]

      def all(options = {})
        params = {}
        add_pagination_params(params, options)
        parse(
          coda_api_get("/docs/#{doc.id}/tables", params: params),
          with: ResponseParsers::List.new,
          doc: doc,
        )
      end

      def get(id)
        parse(
          coda_api_get("/docs/#{doc.id}/tables/#{id}"),
          with: ResponseParsers::Resource.new,
          doc: doc,
        )
      end
    end

    class Columns < CodaHttpClient
      extend TakesMacro
      takes [:api_token!, :doc!, :table!, :client!]

      def all(options = {})
        params = {}
        add_pagination_params(params, options)
        parse(
          coda_api_get("/docs/#{doc.id}/tables/#{table.id}/columns", params: params),
          with: ResponseParsers::List.new,
          doc: doc,
        )
      end

      def get(id)
        parse(
          coda_api_get("/docs/#{doc.id}/tables/#{table.id}/columns/#{id}"),
          with: ResponseParsers::Resource.new,
          doc: doc,
        )
      end
    end

    class Rows < CodaHttpClient
      takes [:api_token!, :doc!, :table!, :client!]

      def all(options = {})
        params = {}
        add_pagination_params(params, options)
        parse(
          coda_api_get("/docs/#{doc.id}/tables/#{table.id}/rows", params: params),
          with: ResponseParsers::List.new,
          doc: doc,
        )
      end

      def get(id)
        parse(
          coda_api_get("/docs/#{doc.id}/tables/#{table.id}/rows/#{id}"),
          with: ResponseParsers::Resource.new,
          doc: doc,
        )
      end

      def insert(rows, options = {})
        payload = {
          rows: rows.map do |row|
            {
              cells: row.map do |column, value|
                column_id = if column.is_a?(Resources::Column)
                              column.id
                            else
                              column
                            end

                {
                  column: column_id,
                  value: value,
                }
              end
            }
          end,
        }

        if options[:key_column_ids]
          payload[:keyColumns] = options.fetch(:key_column_ids)
        end

        if options[:key_columns]
          payload[:keyColumns] = options.fetch(:key_columns).map(&:id)
        end

        parse(
          coda_api_post(
            "/docs/#{doc.id}/tables/#{table.id}/rows",
            payload: payload,
          ),
          with: ResponseParsers::DontParse.new,
          doc: doc,
        )
      end

      def update(id, row)
        payload = {
          row: {
            cells: row.map do |column, value|
              column_id = if column.is_a?(Resources::Column)
                            column.id
                          else
                            column
                          end

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
          doc: doc,
        )
      end

      def delete(id)
        parse(
          coda_api_delete(
            "/docs/#{doc.id}/tables/#{table.id}/rows/#{id}",
          ),
          with: ResponseParsers::DontParse.new,
          doc: doc,
        )
      end
    end

    class Formulas < CodaHttpClient
      extend TakesMacro
      takes [:api_token!, :doc!, :client!]

      def all(options = {})
        params = {}
        add_pagination_params(params, options)
        parse(
          coda_api_get("/docs/#{doc.id}/formulas", params: params),
          with: ResponseParsers::List.new,
          doc: doc,
        )
      end

      def get(id)
        parse(
          coda_api_get("/docs/#{doc.id}/formulas/#{id}"),
          with: ResponseParsers::Resource.new,
          doc: doc,
        )
      end
    end

    class Controls < CodaHttpClient
      extend TakesMacro
      takes [:api_token!, :doc!, :client!]

      def all(options = {})
        params = {}
        add_pagination_params(params, options)
        parse(
          coda_api_get("/docs/#{doc.id}/controls", params: params),
          with: ResponseParsers::List.new,
          doc: doc,
        )
      end

      def get(id)
        parse(
          coda_api_get("/docs/#{doc.id}/controls/#{id}"),
          with: ResponseParsers::Resource.new,
          doc: doc,
        )
      end
    end

    class UserInfo < CodaHttpClient
      takes [:api_token!]

      def get
        parse(
          coda_api_get("/whoami"),
          with: ResponseParsers::Resource.new,
          doc: nil,
        )
      end

      def client
        nil
      end
    end

    class ResolveBrowserLink < CodaHttpClient
      takes [:api_token!]

      def get(link)
        parse(
          coda_api_get(
            "/resolveBrowserLink",
            params: { url: link },
          ),
          with: ResponseParsers::Resource.new,
          doc: nil,
        )
      end

      def client
        nil
      end
    end

    class NextPageLink < CodaHttpClient
      takes [:client!, :api_token!, :doc!]

      def get(link)
        relative_url = link.sub(API_URL, "")

        parse(
          coda_api_get(relative_url),
          with: ResponseParsers::List.new,
          doc: doc,
        )
      end
    end
  end

  module ResponseParsers
    class List
      def parse(json:, client:, doc:)
        resource_parser = ResponseParsers::Resource.new

        next_page_link = json["nextPageLink"]

        resources = json.fetch("items").map do |item|
          resource_parser.parse(json: item, client: client, doc: doc)
        end

        PaginatedResourceList.new(
          resources: resources,
          next_page_link: next_page_link,
          client: client,
          doc: doc,
        )
      end
    end

    class Resource
      def parse(json:, client:, doc:)
        type = json.fetch("type")

        case type
        when "doc"
          Resources::Doc.new(json: json, client: client)
        when "section"
          Resources::Section.new(json: json, client: client, doc: doc)
        when "folder"
          Resources::Folder.new(json: json, client: client, doc: doc)
        when "table"
          Resources::Table.new(json: json, client: client, doc: doc)
        when "column"
          Resources::Column.new(json: json, client: client, doc: doc)
        when "row"
          Resources::Row.new(json: json, client: client, doc: doc)
        when "formula"
          Resources::Formula.new(json: json, client: client, doc: doc)
        when "control"
          Resources::Controls.new(json: json, client: client, doc: doc)
        when "user"
          Resources::User.new(json: json)
        when "apiLink"
          Resources::ApiLink.new(json: json)
        else
          raise "Unknown type: #{type.inspect}"
        end
      end
    end

    class DontParse
      def parse(options)
        options.fetch :json
      end
    end
  end

  class PaginatedResourceList < SimpleDelegator
    def initialize(resources:, next_page_link:, client:, doc:)
      super(resources)
      @next_page_link = next_page_link
      @client = client
      @doc = doc
    end

    def next_page?
      !!next_page_link
    end

    def next_page
      client.next_page(doc, next_page_link)
    end

    private

    attr_reader :client, :next_page_link, :doc
  end
end
