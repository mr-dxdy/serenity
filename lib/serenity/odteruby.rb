module Serenity
  class OdtEruby
    include Debug

    EMBEDDED_PATTERN = /\{%([=%]+)?(.*?)-?%\}/m

    attr_reader :template

    def initialize template
      @template = template
    end

    def src
      @src ||= begin
        script = convert_to_ruby_script template

        if debug?
          File.open(debug_file_path, 'w') { |f| f << script }
        end

        script
      end
    end

    def evaluate context
      encoding_src = src.force_encoding Encoding.default_external
      eval(encoding_src, context)
    end

    def raw_lines
      @sugar_lines ||= convert_to_raw_lines template
    end

    def lines
      @lines ||= SyntacticSugar.all.translate(raw_lines)
    end

    private

    def convert_to_ruby_script(template)
      src = "_buf = '';"
      lines.each { |line| src << line.to_buf }
      src << "\n_buf.to_s\n"
    end

    def convert_to_raw_lines(template)
      buffer = []
      buffer_next = []

      template.each_node do |node, type|
        if !buffer_next.empty?
          if is_matching_pair?(buffer.last, node)
            buffer.pop
            next
          elsif is_nonpair_tag? node
            next
          else
            buffer << buffer_next
            buffer.flatten!
            buffer_next = []
          end
        end

        if type == NodeType::CONTROL
          buffer_next = process_instruction(node)
        else
          buffer << process_instruction(node)
          buffer.flatten!
        end
      end

      buffer
    end

    def process_instruction text
      #text = text.strip
      pos = 0
      src = []

      text.scan(EMBEDDED_PATTERN) do |indicator, code|
        m = Regexp.last_match
        middle = text[pos...m.begin(0)]
        pos  = m.end(0)
        src << Line.text(middle) unless middle.empty?

        if !indicator            # <% %>
          src << Line.code(code)
        elsif indicator == '='   # <%= %>
          src << Line.string(code)
        elsif indicator == '%'   # <%% %>
          src << Line.literal(code)
        end
      end

      rest = pos == 0 ? text : text[pos..-1]

      src << Line.text(rest) unless rest.nil? or rest.empty?
      src
    end

    def is_nonpair_tag? tag
      tag =~ /<.+?\/>/
    end

    def is_matching_pair? open, close
      open = open.to_s.strip
      close = close.to_s.strip

      close == "</#{open[1, close.length - 3]}>"
    end
  end
end
