# spec/models/document_spec.rb
require 'rails_helper'

RSpec.describe Document, type: :model do
  describe 'upload de arquivo' do
    let(:user) { create(:user) }
    let(:xml_file) { File.open(Rails.root.join('spec', 'fixtures', 'files', 'sample.xml')) }
    let(:document) { Document.new(file: xml_file, user: user) }

    it 'é válido com um arquivo XML' do
      expect(document).to be_valid
    end

    it 'salva o arquivo com sucesso' do
      expect { document.save! }.to change { Document.count }.by(1)
      expect(document.file_data).to be_present
    end

    it 'associa o documento ao usuário' do
      document.save!
      expect(document.user).to eq(user)
    end

    it 'processa o arquivo XML corretamente' do
      document = Document.new(user: user, file: xml_file)
      document.save
      
      # Abre o arquivo salvo e lê seu conteúdo
      xml_tempfile = document.file.download
      xml_content = File.read(xml_tempfile.path)

     # Verifica se o conteúdo do arquivo é um XML válido
      expect(xml_content).to include('<?xml') # Checa se o conteúdo é XML

      # Fecha e remove o arquivo temporário
      xml_tempfile.close
      xml_tempfile.unlink
    end

    it 'é inválido sem um arquivo' do
      document.file = nil
      expect(document).not_to be_valid
    end
  end
end
