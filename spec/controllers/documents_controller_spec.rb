require 'rails_helper'

RSpec.describe DocumentsController, type: :controller do
  let(:user) { create(:user) }
  let(:xml_file) { fixture_file_upload(Rails.root.join('spec/fixtures/files/sample.xml'), 'text/xml') }

  before do
    sign_in user
  end

  describe 'GET #new' do
    it 'retorna um novo documento' do
      get :new
      expect(assigns(:document)).to be_a_new(Document)
      expect(response).to render_template(:new)
    end
  end

  describe 'POST #create' do
    it 'cria um novo documento e enfileira um job' do
      expect {
        post :create, params: { document: { file: xml_file } }
      }.to change(Document, :count).by(1)

      expect(flash[:notice]).to eq('Documento salvo com sucesso.')
      expect(response).to redirect_to(documents_path)
      
      # Verifique se o job foi enfileirado
      expect(ProcessXmlJob).to have_been_enqueued.with(Document.last.id)
    end
  end

  describe 'GET #show' do
    it 'exibe o documento e processa o XML' do
      expect(response).to have_http_status(:success)  
    end
  end
end
