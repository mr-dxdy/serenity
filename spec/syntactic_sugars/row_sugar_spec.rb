require 'spec_helper'

describe Serenity::RowSugar do
  context 'case 1' do
    let(:xml) do
      <<~XML.strip
      <table:table>
        <table:table-column table:style-name=""/>
        <table:table-column table:style-name=""/>
        <table:table-column table:style-name=""/>
        <table:table-row>
          <table:table-cell table:number-columns-spanned="3" office:value-type="string">
            <text:p text:style-name="P3">{% merge_rows_tag(@persons, col: 2) do |person, builder| %}</text:p>
          </table:table-cell>
          <table:covered-table-cell/>
          <table:covered-table-cell/>
        </table:table-row>
        <table:table-row>
          <table:table-cell office:value-type="string">
            <text:p text:style-name="Table_20_Contents">{%= person.name %}</text:p>
          </table:table-cell>
          <table:table-cell office:value-type="string">
            <text:p text:style-name="P4">{%= @persons.count %}</text:p>
          </table:table-cell>
          <table:table-cell office:value-type="string">
            <text:p text:style-name="P6">5</text:p>
          </table:table-cell>
        </table:table-row>
        <table:table-row>
          <table:table-cell table:number-columns-spanned="3" office:value-type="string">
            <text:p text:style-name="P2">{% end %}</text:p>
          </table:table-cell>
          <table:covered-table-cell/>
          <table:covered-table-cell/>
        </table:table-row>
      </table:table>
      XML
    end

    let(:lines_parser) do
      Serenity::OdtEruby.new(
        Serenity::XmlReader.new(xml)
      )
    end

    it do
      result = subject.translate lines_parser.raw_lines
      ruby_script = result.map(&:to_buf).join("\n")

      expect(ruby_script).to be_include '_buf << (\'<table:table-cell office:value-type="string" table:number-rows-spanned="%{rows_count}">\' % { rows_count: builder.count }).to_s;'
      expect(ruby_script).to be_include '<table:covered-table-cell/>'
    end
  end
end
