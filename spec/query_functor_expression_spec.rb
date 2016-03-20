require 'spec_helper'

describe RDF::AllegroGraph::Query::FunctorExpression do
  subject do
    functor = RDF::AllegroGraph::Query::FunctorExpression
    functor.new('ego-group-member', EX.me, 2, FOAF.knows, :person)
  end

  it "has a name" do
    expect(subject.name).to eq('ego-group-member')
  end

  it "has a list of arguments" do
    expect(subject.size).to eq(4)
    expect(subject.arguments[0]).to eq(EX.me)
    expect(subject.arguments[1]).to be_kind_of(RDF::Literal)
    expect(subject.arguments[1]).to eq(RDF::Literal.new(2))
    expect(subject.arguments[2]).to eq(FOAF.knows)
    expect(subject.arguments[3]).to be_instance_of(RDF::Query::Variable)
  end

  describe "#variables" do
    it "returns a hash table of all variables in the functor" do
      expect(subject.variables[:person]).to be_instance_of(RDF::Query::Variable)
    end
  end

  describe "#to_prolog" do
    before do
      @repository = RDF::AllegroGraph::Repository.new(REPOSITORY_OPTIONS)
    end

    it "serializes a functor as a Prolog query term" do
      expect(subject.to_prolog(@repository)).to eq <<EOD.chomp
(ego-group-member !<http://example.com/me> !"2"^^<http://www.w3.org/2001/XMLSchema#integer> !<http://xmlns.com/foaf/0.1/knows> ?person)
EOD
    end
  end
end
