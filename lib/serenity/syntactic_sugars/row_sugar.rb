module Serenity
  class RowSugar < ApplicationSugar
    def translate(lines)
      result = []
      begin_index = nil

      lines.each_with_index do |line, index|
        if begin_construction? line
          begin_index = index
        elsif begin_index && end_construction?(line)
          result += translate_construction(lines.slice(begin_index, index - begin_index + 1))
          begin_index = nil
        elsif begin_index.nil?
          result << line
        end
      end

      result
    end

    private

    def begin_construction?(line)
      line.is_a?(Serenity::CodeLine) && line.text.include?('merge_rows_tag')
    end

    def end_construction?(line)
      line.is_a?(Serenity::CodeLine) && line.text.include?('end')
    end

    def begin_cell?(line)
      line.is_a?(Serenity::TextLine) && line.text.include?('<table:table-cell')
    end

    def end_cell?(line)
      line.is_a?(Serenity::TextLine) && line.text.include?('</table:table-cell>')
    end

    def add_attribute_to_other_row(lines, options)
      curr_col, curr_index = 0, 0
      result = []

      while curr_index < lines.length
        curr_col = curr_col + 1 if begin_cell? lines[curr_index]

        if curr_col == options[:col]
          result << Line.text("<table:covered-table-cell/>")
          break
        else
          result << lines[curr_index]
        end

        curr_index = curr_index + 1
      end

      while curr_index < lines.length
        if end_cell? lines[curr_index]
          curr_index = curr_index + 1
          break
        end

        curr_index = curr_index + 1
      end

      while curr_index < lines.length
        result << lines[curr_index]
        curr_index = curr_index + 1
      end

      result
    end

    def add_attribute_to_first_row(lines, options)
      curr_col = 0

      found_index = lines.index do |line|
        curr_col = curr_col + 1 if begin_cell? line
        curr_col == options[:col]
      end

      cloned_lines = lines.map(&:clone)

      if found_index
        cloned_lines[found_index].set_attribute 'table:number-rows-spanned', '%{rows_count}'
        cloned_lines[found_index] = Line.literal("'#{cloned_lines[found_index]}' % { rows_count: builder.count }")
      end

      cloned_lines
    end

    def translate_construction(lines)
      first_line, last_line = lines[0], lines[lines.length - 1]

      ruby_code = [first_line, last_line].join(" ; ")
      # TODO: symbolize hash
      construction_options = RubyLexer::Method.parse_hash_from_arguments_or_empty ruby_code
      construction_lines = lines.slice(1, lines.length - 2)

      result = [first_line]
      result << Line.code(" if builder.index == 0 ")
      result += add_attribute_to_first_row(construction_lines, construction_options)
      result << Line.code(" else ")
      result += add_attribute_to_other_row(construction_lines, construction_options)
      result << Line.code(" end ")
      result << last_line

      result
    end
  end
end
