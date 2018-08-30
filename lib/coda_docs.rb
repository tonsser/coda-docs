require "takes_macro"
require "coda_docs/version"
require "coda_docs/http"
require "coda_docs/client"
require "coda_docs/resources"

module CodaDocs
  class << self
    def client(api_token:)
      Client.new(api_token: api_token)
    end
  end
end
