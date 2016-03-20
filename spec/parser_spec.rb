require 'spec_helper'

module RDF::AllegroGraph

  describe Parser do

    describe ".parse_uri" do
      before do
        allow(Catalog).to receive(:new)
        allow(Server).to receive(:new)
      end

      it 'should parse a root-catalog repository' do
        hash = Parser::parse_uri("#{REPOSITORY_OPTIONS[:url]}/repositories/repo_name")
        expect(hash) .to have_key(:server)
        expect(hash) .to have_key(:catalog)
        expect(hash[:id]).to eq('repo_name')
      end

      it 'should parse a user-catalog repository' do
        hash = Parser::parse_uri("#{REPOSITORY_OPTIONS[:url]}/catalogs/cat_name/repositories/repo_name")
        expect(hash).to     have_key(:catalog)
        expect(hash).not_to have_key(:server)
        expect(hash[:id]).to eq('repo_name')
      end

    end

  end

end
