module Serenity
  module RubyLexer
    class Method
      class << self
        def parse_hash_from_arguments_or_empty(text)
          parser = new
          parser.parse text
          parser.hash_from_arguments_or_empty
        end
      end

      attr_accessor :method_name, :arguments

      # TODO: Do parse case:
      #   build_table(@persons)
      #   build_table(persons)
      def parse(text)
        instance_eval text
        true
      end

      def method_missing(method_name, *args, &block)
        self.method_name = method_name
        self.arguments = args
      end

      def respond_to_missing?(method_name, include_private = false)
        super
      end

      def arguments_or_empty
        arguments || []
      end

      def hash_from_arguments
        self.arguments_or_empty.find { |arg| arg.is_a? Hash }
      end

      def hash_from_arguments_or_empty
        hash_from_arguments || {}
      end
    end
  end
end
