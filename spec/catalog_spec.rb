require 'spec_helper'

describe RDF::AllegroGraph::Catalog do
  before :each do
    @catalog = RDF::AllegroGraph::Catalog.new({:server => REPOSITORY_OPTIONS[:server], :id => CATALOG_REPOSITORY_OPTIONS[:catalog_id]})
  end

  describe ".new" do
    it "allows the user to pass a catalog URL" do
      url = "#{REPOSITORY_OPTIONS[:url]}/catalogs/#{CATALOG_REPOSITORY_OPTIONS[:catalog_id]}"
      @catalog2 = RDF::AllegroGraph::Catalog.new(url)
    end
  end

  describe "catalog creation and deletion" do
    it "is performed using #new with :create and delete!" do
      server = REPOSITORY_OPTIONS[:server]
      @catalog2 = RDF::AllegroGraph::Catalog.new({:server => REPOSITORY_OPTIONS[:server], :id => 'rdf_agraph_test_2' }, :create => true)
      expect(server.has_catalog?('rdf_agraph_test_2')).to be true
      @catalog2.delete!
      expect(server.has_catalog?('rdf_agraph_test_2')).to be false
    end
  end

  it "returns available repositories" do
    expect(@catalog).to respond_to(:repositories)
    expect(@catalog.repositories).to be_a_kind_of(Enumerable)
    expect(@catalog.repositories).to be_instance_of(Hash)
    @catalog.repositories.each do |identifier, repository|
      expect(identifier).to be_instance_of(String)
      expect(repository).to be_instance_of(RDF::AllegroGraph::Repository)
    end
  end

  it "indicates whether a repository exists" do
    expect(@catalog).to respond_to(:has_repository?)
    expect(@catalog.has_repository?(CATALOG_REPOSITORY_OPTIONS[:id])).to be true
    expect(@catalog.has_repository?(:foobar)).to be false
  end

  it "returns existing repositories" do
    expect(@catalog).to respond_to(:repository, :[])
    repository = @catalog.repository(CATALOG_REPOSITORY_OPTIONS[:id])
    expect(repository).not_to be_nil
    expect(repository).to     be_instance_of(RDF::AllegroGraph::Repository)
  end

  it "does not return nonexistent repositories" do
    expect(lambda { @catalog.repository(:foobar) }).to_not raise_error
    repository = @catalog.repository(:foobar)
    expect(repository).to be_nil
  end

  it "supports enumerating repositories" do
    expect(@catalog).to respond_to(:each_repository, :each)
    # @server.each_repository.should be_an_enumerator
    @catalog.each_repository do |repository|
      expect(repository).to be_instance_of(RDF::AllegroGraph::Repository)
    end
  end
end
