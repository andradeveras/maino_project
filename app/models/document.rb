class Document < ApplicationRecord
  belongs_to :user

  validates :file_data, presence: true

  include DocumentUploader::Attachment(:file)
  include Shrine::Attachment(:file) # Supondo que o campo de arquivo é chamado 'file'

  # Método para processar o XML
  def parsed_xml
    return unless file.present?

    xml_content = file.download
    Nokogiri::XML(xml_content)
  end
end
