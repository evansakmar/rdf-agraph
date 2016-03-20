require 'spec_helper'

describe RDF::AllegroGraph::Server do
  # These tests are copied from
  # https://github.com/bendiken/rdf-sesame/blob/master/spec/server_spec.rb
  # and modified to remove 'url' and 'connection'.
  describe "RDF::Sesame compatibility" do
    before :each do
      @url    = REPOSITORY_OPTIONS[:url]
      @server = RDF::AllegroGraph::Server.new(@url)
    end

    it "returns the protocol version" do
      expect(@server).to respond_to(:protocol, :protocol_version)
      expect(@server.protocol).to be_a_kind_of(Numeric)
      expect(@server.protocol).to be >= 4
    end

    it "returns available repositories" do
      expect(@server).to respond_to(:repositories)
      expect(@server.repositories).to be_a_kind_of(Enumerable)
      expect(@server.repositories).to be_instance_of(Hash)
      @server.repositories.each do |identifier, repository|
        expect(identifier).to be_instance_of(String)
        expect(repository).to be_instance_of(RDF::AllegroGraph::Repository)
      end
    end

    it "indicates whether a repository exists" do
      expect(@server).to respond_to(:has_repository?)
      expect(@server.has_repository?(REPOSITORY_OPTIONS[:id])).to be_truthy
      expect(@server.has_repository?(:foobar)).to be_falsey
    end

    it "returns existing repositories" do
      expect(@server).to respond_to(:repository, :[])
      repository = @server.repository(REPOSITORY_OPTIONS[:id])
      expect(repository).not_to be_nil
      expect(repository).to be_instance_of(RDF::AllegroGraph::Repository)
    end

    it "does not return nonexistent repositories" do
      expect { @server.repository(:foobar) }.not_to raise_error
      repository = @server.repository(:foobar)
      expect(repository).to be_nil
    end

    it "supports enumerating repositories" do
      expect(@server).to respond_to(:each_repository, :each)
      # @server.each_repository.should be_an_enumerator
      @server.each_repository do |repository|
        expect(repository).to be_instance_of(RDF::AllegroGraph::Repository)
      end
    end

    it "returns available catalogs" do
      expect(@server).to respond_to(:catalogs)
      expect(@server.catalogs).to be_a_kind_of(Enumerable)
      expect(@server.catalogs).to be_instance_of(Hash)
      @server.catalogs.each do |identifier, catalog|
        expect(identifier).to be_instance_of(String)
        expect(catalog).to be_instance_of(RDF::AllegroGraph::Catalog)
      end
    end

    it "indicates whether a catalog exists" do
      expect(@server).to respond_to(:has_catalog?)
      expect(@server.has_catalog?(CATALOG_REPOSITORY_OPTIONS[:catalog_id])).to be_truthy
      expect(@server.has_catalog?(:foobar)).to be_falsey
    end

    it "returns existing catalog" do
      expect(@server).to respond_to(:catalog)
      catalog = @server.catalog(CATALOG_REPOSITORY_OPTIONS[:catalog_id])
      expect(catalog).not_to be_nil
      expect(catalog).to be_instance_of(RDF::AllegroGraph::Catalog)
    end

    it "does not return nonexistent catalogs" do
      expect { @server.catalog(:foobar) }.not_to raise_error
      catalog = @server.catalog(:foobar)
      expect(catalog).to be_nil
    end

    it "supports enumerating catalogs" do
      expect(@server).to respond_to(:each_catalog, :each)
      # @server.each_repository.should be_an_enumerator
      @server.each_catalog do |catalog|
        expect(catalog).to be_instance_of(RDF::AllegroGraph::Catalog)
      end
    end

    it "returns the initfile" do
      expect(@server).to respond_to(:initfile)
      content = @server.initfile || ""
      expect(content).to be_instance_of(String)
    end

    it "list scripts" do
      expect(@server).to respond_to(:scripts)
    end

    it "create scripts" do
      expect(@server).to respond_to(:save_script)
      @server.save_script 'subfolder/script', ';; COMMENT'
      expect(@server.scripts).to include 'subfolder/script'
    end

    it "get scripts" do
      expect(@server).to respond_to(:get_script)
      expect(@server.get_script('subfolder/script')).to eq(';; COMMENT')
    end

    it "remove scripts" do
      expect(@server).to respond_to(:remove_script)
      @server.remove_script('subfolder/script')
      expect(@server.scripts).not_to include 'subfolder/script'
    end
  end
end
