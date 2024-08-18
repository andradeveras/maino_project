# spec/models/document_spec.rb

require 'rails_helper'

RSpec.describe Document, type: :model do
  let(:user) { User.create(email: 'user@example.com', password: 'password') }

  before do
    @document = Document.new(user: user) # Cria um documento sem o campo 'file'
  end

  it 'is invalid without a file' do
    expect(@document).not_to be_valid
    expect(@document.errors[:file]).to include("can't be blank")
  end

  it 'is valid with a file' do
    file_path = Rails.root.join('spec', 'fixtures', 'files', 'sample.xml')
    file = File.open(file_path)
    @document.file = file
    expect(@document).to be_valid
    file.close
  end

  it 'is invalid without a user' do
    file_path = Rails.root.join('spec', 'fixtures', 'files', 'sample.xml')
    file = File.open(file_path)
    @document.file = file
    @document.user = nil
    expect(@document).not_to be_valid
    expect(@document.errors[:user]).to include("can't be blank")
    file.close
  end
end
