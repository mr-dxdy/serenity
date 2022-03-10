module Serenity
  module TablesHelper
    def build_table(items, options = {}, &block)
      items.each_with_index do |item, index|
        yield(item, index)
      end
    end
  end
end
