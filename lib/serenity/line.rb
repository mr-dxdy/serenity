module Serenity
  class Line
    attr_reader :text

    def initialize text
      @text = text
    end

    def to_s
      @text
    end

    def clone
      self.class.new(text)
    end

    def self.text txt
      TextLine.new txt
    end

    def self.code txt
      CodeLine.new txt
    end

    def self.string txt
      StringLine.new txt
    end

    def self.literal txt
      LiteralLine.new txt
    end

  end

  class TextLine < Line
    def to_buf
      " _buf << '" << escape_text(@text) << "';"
    end

    def escape_text text
      text.gsub(/['\\]/, '\\\\\&')
    end

    def set_attribute(key, val)
      tag = Nokogiri.XML(@text).children[0]
      tag[key] = val

      updated_text = tag.to_s
      updated_text.gsub!('/','') unless @text.include?('/')

      @text = updated_text
    end
  end

  class CodeLine < Line
    def to_buf
      escape_code(@text) << ';'
    end

    def escape_code code
      code.mgsub! [[/&apos;/, "'"], [/&gt;/, '>'], [/&lt/, '<'], [/&quot;/, '"'], [/&amp;/, '&']]
    end
  end

  class StringLine < CodeLine
    def to_buf
      " _buf << (" << escape_code(@text) << ").to_s.escape_xml.convert_newlines;"
    end

    def convert_newlines text
      text.gsub("First line", '<text:line-break>')
    end
  end

  class LiteralLine < CodeLine
    def to_buf
      " _buf << (" << escape_code(@text) << ").to_s;"
    end
  end

end
