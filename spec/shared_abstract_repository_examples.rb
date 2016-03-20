require 'rdf/spec/repository'

RSpec::Matchers.define :include_solution do |hash|
  match do |solutions|
    solutions.any? {|s| s.to_hash == hash }
  end
end

shared_examples_for RDF::AllegroGraph::AbstractRepository do
  # This pulls in a huge number of specifications from rdf-spec, ensuring
  # that we implement the standard API correctly.
  include RDF_Repository

  describe "#supports?" do
    it "returns true if passed :context" do
      expect(@repository.supports?(:context)).to eq(true)
    end

    it "returns false if passed an unsupported feature" do
      expect(@repository.supports?(:no_such_feature)).to eq(false)
    end
  end

  context "with example data" do
    before :each do
      path = File.join(File.dirname(__FILE__), '..', 'etc', 'doap.nt')
      @repository.load(path)
    end

    describe "#size" do
      it "returns the amount of statements in the repository" do
        expect(@repository.size).to eql(73)
      end
    end

    describe "#insert_statements (protected)" do
      let(:statement) { [RDF::Statement.new(RDF::URI("http://ar.to/#someone"), FOAF.mbox, RDF::URI("mailto:someone@gmail.com"))] }

      context "with :json format" do
        before { @repository.insert_options = { :format => :json } }
        it "should use a JSON request to send the statements" do
          expect(@repository.resource_writable).to receive(:request_json).at_least(:once).and_call_original
          @repository.send(:insert_statements, statement)
        end
      end

      context "with :ntriples format" do
        before { @repository.insert_options = { :format => :ntriples } }
        it "should use a HTTP request to send the statements" do
          expect(@repository.resource_writable).to receive(:request_http).at_least(:once).and_call_original
          @repository.send(:insert_statements, statement)
        end
      end
    end

    describe "#delete_statement (protected)" do
      it "deletes a single, valid statement" do
        stmt = RDF::Statement.new(RDF::URI("http://ar.to/#self"),
                                  FOAF.mbox,
                                  RDF::URI("mailto:arto.bendiken@gmail.com"))
        expect(@repository).to have_statement(stmt)
        # This method is protected, but we're required to override it.
        # Unfortuantely, because we also override delete_statements,
        # there's no way for it to get called using public APIs.  So we
        # bypass the 'protected' restriction using 'send'.
        @repository.send(:delete_statement, stmt)
        expect(@repository).not_to have_statement(stmt)
      end
    end

    describe "#sparql_query" do

      context "when SELECT query" do
        it "matches a SPARQL query" do
          s = @repository.sparql_query("SELECT ?name WHERE { <http://ar.to/#self> <http://xmlns.com/foaf/0.1/name> ?name }")
          expect(s).to be_kind_of(enumerator_class)
          expect(s).to include_solution(:name => "Arto Bendiken")
        end
      end

      context "when CONSTRUCT query" do
        it "matches a SPARQL query" do
          s = @repository.sparql_query("CONSTRUCT { <http://ar.to/#self> <http://xmlns.com/foaf/0.1/name> ?name } WHERE { <http://ar.to/#self> <http://xmlns.com/foaf/0.1/name> ?name }")
          expect(s).to be_kind_of(RDF::Graph)
          expect(s).to have_statement(RDF::Statement.new(RDF::URI('http://ar.to/#self'), RDF::URI('http://xmlns.com/foaf/0.1/name'), RDF::Literal('Arto Bendiken')))
        end
      end

    end

    describe "#prolog_query" do
      it "matches a Prolog query" do
        s = @repository.prolog_query(<<EOD)
(select (?name)
  (q- !<http://ar.to/#self> !<http://xmlns.com/foaf/0.1/name> ?name))
EOD
        expect(s).to be_kind_of(enumerator_class)
        expect(s).to include_solution(:name => "Arto Bendiken")
      end
    end

    describe "#query_options" do
      it "add parameters to each query" do
        @repository.query_options = { :limit => 1, :offset => 1 }
        s = @repository.sparql_query("SELECT ?person WHERE { ?person a <http://xmlns.com/foaf/0.1/Person> }")
        expect(s).not_to include_solution(:person => "http://ar.to/#self")
        expect(s).to include_solution(:person => "http://bhuga.net/#ben")
      end
    end

    describe "#build_query" do
      it "creates a new query" do
        query = @repository.build_query do |q|
          q.pattern [:person, RDF.type, FOAF.Person]
        end
        expect(query).to be_kind_of(RDF::AllegroGraph::Query)
        expect(query.patterns.length).to eq(1)
      end
    end

    describe "#query on a Basic Graph Pattern" do
      it "matches all required patterns" do
        query = RDF::Query.new do |q|
          q.pattern [:person, RDF.type, FOAF.Person]
          q.pattern [:person, FOAF.name, :name]
          q.pattern [:person, FOAF.mbox, :email]
        end
        s = @repository.query(query).to_a
        expect(s).to include_solution(:person => "http://ar.to/#self",
                                  :name => "Arto Bendiken",
                                  :email => "mailto:arto.bendiken@gmail.com")
        expect(s).to include_solution(:person => "http://bhuga.net/#ben",
                                  :name => "Ben Lavender",
                                  :email => "mailto:blavender@gmail.com")
        expect(s).to include_solution(:person => "http://kellogg-assoc.com/#me",
                                  :name => "Gregg Kellogg",
                                  :email => "mailto:gregg@kellogg-assoc.com")
      end

      it "match optional patterns when appropriate" do
        query = RDF::Query.new do |q|
          q.pattern [:person, RDF.type, FOAF.Person]
          q.pattern [:person, FOAF.made, :made], :optional => true
        end
        s = @repository.query(query).to_a
        expect(s).to include_solution(:person => "http://ar.to/#self",
                                  :made => "http://rubygems.org/gems/rdf")
        expect(s).to include_solution(:person => "http://bhuga.net/#ben")
        expect(s).to include_solution(:person => "http://kellogg-assoc.com/#me")
      end

      it "runs AllegroGraph-specific queries" do
        query = @repository.build_query do |q|
          q.pattern [:person, RDF.type, FOAF.Person]
          q.pattern [:person, FOAF.name, "Arto Bendiken"]
        end
        s = @repository.query(query).to_a
        expect(s).to include_solution(:person => "http://ar.to/#self")
      end

      # TODO: RDF::Query::Pattern doesn't really support contexts yet,
      # so we can't try to match it.
      #context "with contexts" do
      #  before do
      #    @repository.insert([EX.s1, EX.p, EX.o],
      #                       [EX.s2, EX.p, EX.o, EX.c2])
      #  end
      #
      #  it "matches statements with and without a context" do
      #    query = RDF::Query.new {|q| q.pattern [:s, EX.p, EX.o] }
      #    s = @repository.query(query).to_a
      #    s.should include_solution(:s => EX.s1)
      #    s.should include_solution(:s => EX.s2)
      #  end
      #end
    end

    describe "blank node mapping" do
      it "correctly handle blank nodes that originate in the repository" do
        @repository2 = RDF::AllegroGraph::Repository.new(REPOSITORY_OPTIONS)
        @repository2.each {|stmt| expect(@repository2).to have_statement(stmt) }
      end
    end
  end

  describe "#serialize" do
    it "transforms RDF::Value objects into strings" do
      expect(@repository.serialize(RDF::URI("http://example.com/"))).to eq(
        "<http://example.com/>"
      )
      expect(@repository.serialize(RDF::Literal.new("string"))).to eq("\"string\"")
    end

    it "maps blank nodes to a server-specific representation" do
      expect(@repository.serialize(RDF::Node.intern('x'))).not_to eq("_:x")
    end

    it "serializes variables with a leading '?'" do
      expect(@repository.serialize(RDF::Query::Variable.new(:x))).to eq("?x")
    end
  end

  describe "#serialize_prolog" do
    it "prefixes RDF values with an !" do
      expect(@repository.serialize_prolog(RDF::URI("http://example.com/"))).to eq(
        "!<http://example.com/>"
      )
      expect(@repository.serialize_prolog(RDF::Literal.new("foo"))).to eq("!\"foo\"")
    end

    it "serializes variables without a leading !" do
      expect(@repository.serialize_prolog(RDF::Query::Variable.new(:x))).to eq("?x")
    end

    it "serializes Prolog literals" do
      literal = RDF::AllegroGraph::Query::PrologLiteral.new(:foo)
      expect(@repository.serialize_prolog(literal)).to eq("foo")
    end
  end
end
