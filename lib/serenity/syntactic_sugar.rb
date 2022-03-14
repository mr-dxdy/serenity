require_relative "./syntactic_sugars/application_sugar"
require_relative "./syntactic_sugars/row_sugar"

module Serenity
  class SyntacticSugar
    class << self
      def all
        new [RowSugar.new]
      end
    end

    attr_reader :sugars

    def initialize(sugars = [])
      @sugars = sugars
    end

    def translate(lines)
      sugars.inject(lines) do |output, sugar|
        sugar.translate(output)
      end
    end
  end
end
