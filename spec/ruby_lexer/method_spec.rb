require 'spec_helper'

describe Serenity::RubyLexer::Method do
  subject { described_class.new }

  it 'with instance variables' do
    subject.parse "build_table(@persons)"

    expect(subject.method_name).to eq :build_table
    expect(subject.arguments).to eq [nil]
  end

  it 'with global variables' do
    subject.parse "build_table(persons)"

    expect(subject.method_name).to eq :build_table
    expect(subject.arguments).to eq [[]]
  end

  it 'with hash' do
    subject.parse "build_table(persons, {a: 10, b: 20})"

    expect(subject.method_name).to eq :build_table
    expect(subject.arguments).to eq [[], {a: 10, b: 20}]
  end
end
