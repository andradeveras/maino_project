# app/jobs/process_xml_job.rb
class ProcessXmlJob < ApplicationJob
  queue_as :default

  def perform(document_id)
    document = Document.find(document_id)
    
    # Baixe o conteúdo do arquivo XML
    xml_content = document.file.download
    
    # Processa o XML
    process_xml(xml_content)
  end

  private

  def process_xml(xml_content)
    # Aqui você pode adicionar a lógica para processar o XML
    # Exemplo: Parse e extrair dados do XML
    require 'nokogiri'

    # Usando Nokogiri para parsear o XML
    xml = Nokogiri::XML(xml_content)

    # Adicione aqui o código para processar o conteúdo XML
    # Exemplo: Encontrar todos os elementos <item> e imprimir seu conteúdo
    xml.xpath('//item').each do |item|
      puts "Item: #{item.text}"
    end
  end
end
