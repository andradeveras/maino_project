require 'rails_helper'

RSpec.describe DocumentsController, type: :controller do
  let(:user) { create(:user) }
  let(:document) { create(:document, user: user) }

  before do
    sign_in user
  end

  describe 'GET #new' do
    it 'assigns a new document to @document' do
      get :new
      expect(assigns(:document)).to be_a_new(Document)
    end
  end

  describe 'POST #create' do
    context 'with valid attributes' do
      it 'creates a new document' do
        expect {
          post :create, params: { document: { file: fixture_file_upload('files/sample.xml', 'application/xml') } }
        }.to change(Document, :count).by(1)
      end

      it 'redirects to the documents index' do
        post :create, params: { document: { file: fixture_file_upload('files/sample.xml', 'application/xml') } }
        expect(response).to redirect_to(documents_path)
      end
    end

    context 'with invalid attributes' do
      it 'does not save the new document' do
        expect {
          post :create, params: { document: { file: nil } }
        }.not_to change(Document, :count)
      end

      it 're-renders the new template' do
        post :create, params: { document: { file: nil } }
        expect(response).to render_template(:new)
      end
    end
  end

  describe 'GET #show' do
    it 'assigns the requested document to @document' do
      get :show, params: { id: document.id }
      expect(assigns(:document)).to eq(document)
    end

    it 'loads the XML data into @data' do
      get :show, params: { id: document.id }
      expect(assigns(:data)).to be_present
    end
  end

  describe 'GET #download_excel' do
    it 'downloads the Excel file' do
      get :download_excel, params: { id: document.id }
      expect(response.headers['Content-Disposition']).to include('attachment')
      expect(response.content_type).to eq('application/xlsx')
    end
  end
end
