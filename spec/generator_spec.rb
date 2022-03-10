require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Serenity::Generator do
  after(:each) do
    %w[loop_output.odt merged_cells_output.odt].each do |odt_file|
      FileUtils.rm_f fixture(odt_file)
    end
  end

  it 'should make context from instance variables and run the provided template' do
    class GeneratorClient
      include Serenity::Generator

      def generate_odt
        @crew = ['Mal', 'Inara', 'Wash', 'Zoe']

        render_odt fixture('loop.odt')
      end
    end

    client = GeneratorClient.new
    expect { client.generate_odt }.not_to raise_error
    expect( fixture('loop_output.odt') ).to be_a_document
  end

  it 'should use tables helper' do
    class GeneratorTables < ::SimpleDelegator
      include Serenity::Generator

      def initialize(file)
        @file = file

        super(self.helper)
      end

      def generate_odt
        @persons = [Person.new('Malcolm', 'captain'), Person.new('River', 'psychic'), Person.new('Jay', 'gunslinger')]

        render_odt @file
      end
    end

    generator = GeneratorTables.new fixture('merged_cells.odt')
    expect{ generator.generate_odt }.not_to raise_error
  end
end
