require "coda_docs/string_helpers"
module CodaDocs
  module Resources
    class Resource
      extend TakesMacro
      takes :json

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
              CodaDocs::ResponseParsers::Resource.new.parse(value)
            end
          end
        end
      end

      def self.define_list_getters(*methods)
        methods.each do |method|
          define_method(:children) do
            value_at("children") do |values|
              parser = CodaDocs::ResponseParsers::Resource.new
              values.map { |value| parser.parse(value) }
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
      define_getters(
        :id,
        :type,
        :href,
        :browser_link,
        :name,
        :owner,
      )

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
      define_getters(
        :id,
        :type,
        :href,
      )
    end

    class Section < Resource
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
      define_getters(
        :id,
        :type,
        :href,
        :name,
      )
    end

    class Column < Resource
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
  end
end
