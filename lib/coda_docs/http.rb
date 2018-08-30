require "rest-client"
require "json"

module CodaDocs
  module Http
    class << self
      def get(url, params: {}, headers: {})
        url = if params
                "#{url}?#{to_query_string(params)}"
              else
                url
              end

        response = RestClient::Request.execute(
          url: url,
          method: :get,
          headers: headers,
        )

        Response.from_rest_client_response(response)
      end

      def post(url, payload:, headers: {})
        raise "Invalid payload type: #{payload.class}" unless payload.is_a?(String)

        response = RestClient::Request.execute(
          url: url,
          method: :post,
          payload: payload,
          headers: headers,
        )

        Response.from_rest_client_response(response)
      end

      def put(url, payload:, headers: {})
        raise "Invalid payload type: #{payload.class}" unless payload.is_a?(String)

        response = RestClient::Request.execute(
          url: url,
          method: :put,
          payload: payload,
          headers: headers,
        )

        Response.from_rest_client_response(response)
      end

      def delete(url, headers: {})
        response = RestClient::Request.execute(
          url: url,
          method: :delete,
          headers: headers,
        )

        Response.from_rest_client_response(response)
      end

      private

      def to_query_string(hash)
        hash.map do |key, value|
          escaped = if value.is_a?(String)
                      CGI.escape(value)
                    else
                      value
                    end

          "#{key}=#{escaped}"
        end.join("&")
      end
    end

    class Response
      def self.from_rest_client_response(response)
        new(
          get_body: ->() { response.body },
          get_headers: ->() { response.headers },
          get_status: ->() { response.code },
        )
      end

      extend TakesMacro
      takes [:get_body!, :get_headers!, :get_status!]

      def status
        @status ||= @get_status.call
      end

      def success?
        status.to_s.match?(/^2\d\d/)
      end

      def headers
        @headers ||= @get_headers.call
      end

      def body
        @body ||= @get_body.call
      end

      def json
        @json ||= JSON.parse(body)
      end
    end
  end
end
