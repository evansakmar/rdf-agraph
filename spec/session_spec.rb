require 'spec_helper'

describe RDF::AllegroGraph::Session do
  before :each do
    @real_repository = RDF::AllegroGraph::Repository.new(REPOSITORY_OPTIONS)
    @repository = RDF::AllegroGraph::Session.new(@real_repository)
    @statement = RDF::Statement.from([EX.me, RDF.type, FOAF.Person])
  end

  after :each do
    @repository.close unless @repository.nil? # We might have closed it.
    @real_repository.clear
  end

  it_should_behave_like RDF::AllegroGraph::AbstractRepository

  describe "#close" do
    it "destroys the underlying session" do
      @repository.close
      expect { @repository.close }.to raise_error
      @repository = nil
    end

    it "does not commit outstanding transactions" do
      @repository.insert(@statement)
      @repository.close
      @repository = nil
      expect(@real_repository).not_to have_statement(@statement)
    end
  end

  describe "#ping" do
    it "pings the session" do
      expect(@repository.ping).to be_truthy
    end
  end

  describe "#still_alive?" do
    it "indicates if the session is still alive" do
      expect(@repository.still_alive?).to be_truthy
      @repository.close
      expect(@repository.still_alive?).to be_falsey
      @repository = nil
    end
  end

  describe "transaction" do
    before do
      @repository.insert(@statement)
    end

    it "does not show changes to other sessions before commit is called" do
      expect(@real_repository).not_to have_statement(@statement)
    end

    it "shows changes to other sessions after commit is called" do
      @repository.commit
      expect(@real_repository).to have_statement(@statement)
    end

    it "discards changes when rollback is called" do
      @repository.rollback
      expect(@real_repository).not_to have_statement(@statement)
      expect(@repository).not_to have_statement(@statement)
    end
  end

  describe "transaction with autoCommit" do
    before do
      @repository.close
      @repository = RDF::AllegroGraph::Session.new(@real_repository, :session => { :autoCommit => true } )
      @repository.insert(@statement)
    end

    it "show changes to other sessions before commit is called" do
      expect(@real_repository).to have_statement(@statement)
    end
  end

  describe "transaction with a federated store" do
    before do

      REPOSITORY_OPTIONS[:server].repository('rdf_agraph_test_read', :create => true)

      @repository.close
      @repository = RDF::AllegroGraph::Session.new(REPOSITORY_OPTIONS[:server],
        :session => {
          :store => [ REPOSITORY_OPTIONS[:id], 'rdf_agraph_test_read' ],
          :autoCommit => true
        },
        :writable_mirror => @real_repository)
      @repository.insert(@statement)
    end

    it "writes the new statements in the writable mirror" do
      expect(@real_repository).to have_statement(@statement)
    end
  end

end
