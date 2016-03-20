require 'spec_helper'

describe RDF::AllegroGraph::Query::PrologLiteral do
  it "stores symbols" do
    expect(RDF::AllegroGraph::Query::PrologLiteral.new(:knows).to_s).to eq('knows')
  end

  it "stores integers" do
    expect(RDF::AllegroGraph::Query::PrologLiteral.new(2).to_s).to eq("2")
  end
end
