require 'rails_helper'

RSpec.describe 'File Organising API', type: :request do
  # initialize test data
  let!(:document) { create(:document, tags: create_list(:tag, 5)) }
  let!(:documents) { create_list(:document, 4, tags: create_list(:tag, rand(1..5))) }
  let!(:tag_search_query) { "+#{document.tags.first.name}" }
  let(:page) { 1 }

  # Test suite for POST /file
  describe 'POST /file' do
    # valid payload
    let(:valid_attributes) { { "name": "file1", "tags": ["tag1", "tag2"]} }

    context 'when the request is valid' do
      before { post '/file', params: valid_attributes }

      it 'creates a document' do
        expect(json).not_to be_empty
      end

      it 'returns status code 201' do
        expect(response).to have_http_status(201)
      end
    end

    context 'when no tags specified' do
      before { post '/file', params: { name: 'file2' } }

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a validation failure message' do
        expect(response.body)
        .to match(/You have to specify at least one tag!/)
      end
    end

    context 'when tags have wrong format' do
      before { post '/file', params: {"name": "file3", "tags": ["asd", "qw e"]} }

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a validation failure message' do
        expect(response.body)
        .to match(/Invalid characters/)
      end
    end

  end

  # Test suite for get /files/:tag_search_query/:page
  describe 'get /files/:tag_search_query/:page' do
    before { get URI.encode("/files/#{tag_search_query}/#{page}") }

    context 'when the tag search query is valid and will have results' do
      it 'returns the results' do
        expect(json).not_to be_empty
        expect(json['records'].size).to be > 0
        expect(json['related_tags']).not_to be_empty
        expect(json['total_records']).not_to be 0
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when the tag search query is valid but page number is out of bounds' do
      let(:page) { 99999 }
      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'returns a message of number page out of bounds' do
        expect(response.body)
        .to match(/page number is out of bounds/)
      end
    end

    context 'when the tag search query is valid and would not have results' do
      let!(:tag_search_query) { "+thistagdoesntexist" }
      it 'returns no results' do
        expect(json).not_to be_empty
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'returns a message of no results' do
        expect(response.body)
        .to match(/No results for this query/)
      end
    end

    context 'when the tag search query is invalid' do
      let!(:tag_search_query) { "+tag3 tag4" }

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'returns a message of invalid tag search query' do
        expect(response.body)
        .to match(/Invalid search query, it needs to be formated as eg/)
      end
    end

    context 'when the tag search query has not positive tags' do
      let!(:tag_search_query) { "-tag3 -tag2" }

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'returns a message of invalid tag search query' do
        expect(response.body)
        .to match(/Invalid search query, it needs to have at least one positive tag/)
      end
    end

  end

end
