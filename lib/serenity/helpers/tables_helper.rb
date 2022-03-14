module Serenity
  module TablesHelper
    # TODO: Fix static name of variable #builder
    def merge_rows_tag(items, col:)
      items.each_with_index do |item, index|
        yield(
          item,
          OpenStruct.new(subject: item, index: index, count: items.count)
        )
      end
    end
  end
end
