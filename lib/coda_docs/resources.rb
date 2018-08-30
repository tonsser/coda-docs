require "coda_docs/string_helpers"
module CodaDocs
  module Resources
    class Resource
      def method_missing(name, *)
        if name == :json
          @json
        else
          super
        end
      end

      extend TakesMacro

      private

      def self.define_getters(*methods)
        methods.each do |method|
          key = StringHelpers.camelize(method.to_s)

          define_method(method) do
            value_at(key)
          end
        end
      end

      def self.define_single_getters(*methods)
        methods.each do |method|
          define_method(:parent) do
            value_at("parent") do |value|
              CodaDocs::ResponseParsers::Resource.new.parse(
                json: value,
                client: client,
                doc: doc,
              )
            end
          end
        end
      end

      def self.define_list_getters(*methods)
        methods.each do |method|
          define_method(:children) do
            value_at("children") do |values|
              parser = CodaDocs::ResponseParsers::Resource.new
              values.map do |value|
                parser.parse(
                  json: value,
                  client: client,
                  doc: doc,
                )
              end
            end
          end
        end
      end

      def value_at(camel_key)
        value = json.fetch(camel_key)

        if block_given?
          yield value
        else
          value
        end
      end
    end

    class Doc < Resource
      takes [:json!, :client!]

      define_getters(
        :id,
        :type,
        :href,
        :browser_link,
        :name,
        :owner,
      )

      def sections
        client.sections(self)
      end

      def folders
        client.folders(self)
      end

      def tables
        client.tables(self)
      end

      def created_at
        value_at "createdAt", &Time.method(:parse)
      end

      def updated_at
        value_at "updatedAt", &Time.method(:parse)
      end

      def source_doc
        value_at "sourceDoc", &SourceDoc.method(:new)
      end
    end

    class SourceDoc < Resource
      takes [:json!, :client!, :doc!]

      define_getters(
        :id,
        :type,
        :href,
      )
    end

    class Section < Resource
      takes [:json!, :client!, :doc!]

      define_getters(
        :id,
        :type,
        :href,
        :name,
        :browser_link,
      )

      define_single_getters(
        :parent,
      )
    end

    class Folder < Resource
      takes [:json!, :client!, :doc!]

      define_getters(
        :id,
        :type,
        :href,
        :name,
      )

      define_list_getters(
        :children,
      )
    end

    class Table < Resource
      takes [:json!, :client!, :doc!]

      define_getters(
        :id,
        :type,
        :href,
        :name,
      )

      def columns
        client.columns(doc, self)
      end

      def rows
        client.rows(doc, self)
      end
    end

    class Column < Resource
      takes [:json!, :client!, :doc!]

      define_getters(
        :id,
        :type,
        :href,
        :name,
        :display,
        :calculated,
      )

      define_single_getters(
        :parent,
      )
    end

    class Row < Resource
      takes [:json!, :client!, :doc!]

      define_getters(
        :id,
        :type,
        :href,
        :name,
        :index,
        :browser_link,
        :values,
      )

      define_single_getters(
        :parent,
      )

      def created_at
        value_at "createdAt", &Time.method(:parse)
      end

      def updated_at
        value_at "updatedAt", &Time.method(:parse)
      end
    end

    class User < Resource
      takes [:json!]

      define_getters(
        :name,
        :loginId,
        :type,
        :href,
      )
    end

    class ApiLink < Resource
      takes [:json!]

      define_getters(
        :type,
        :href,
        :browser_link,
      )

      def resource
        value_at("resource") { |value| ApiLinkResource.new(json: value) }
      end
    end

    class ApiLinkResource < Resource
      takes [:json!]

      define_getters(
        :href,
      )
    end
  end
end
