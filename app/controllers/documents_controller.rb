class DocumentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_document, only: %i[show]
  require 'nokogiri'

  def new
    @document = Document.new
  end

  def create
    @document = Document.new(document_params)
    @document.user = current_user

    if @document.save
      # Enfileira o job para processamento em background
      ProcessXmlJob.perform_later(@document.id)

      flash[:notice] = "Documento salvo com sucesso."
      redirect_to documents_path
    else
      flash[:alert] = "Falha ao salvar o documento."
      render :new
    end
  end

  def show
    @document = Document.find(params[:id])
    
    if @document.file
      xml_content = @document.file.download
      Rails.logger.debug("Conteúdo do XML: #{xml_content}")
  
      @data = parse_xml(xml_content)
      Rails.logger.debug("Dados extraídos: #{@data.inspect}")
    else
      @data = {}
      Rails.logger.debug("Arquivo não encontrado para o documento ID: #{params[:id]}")
    end
  end

  def index
    @documents = current_user.documents
  end

  private

  def set_document
    @document = Document.find(params[:id])
  end

  def document_params
    params.require(:document).permit(:file)
  end

  def parse_xml(xml_content)
    # Carregar o XML com o namespace
    doc = Nokogiri::XML(xml_content)
    doc.remove_namespaces!# para remover namespaces e simplificar as consultas XPath
  
    {
      serie: doc.at_xpath('//serie')&.text,
      nNF: doc.at_xpath('//nNF')&.text,
      dhEmi: doc.at_xpath('//dhEmi')&.text,
      emit: {
        CNPJ: doc.at_xpath('//emit/CNPJ')&.text,
        xNome: doc.at_xpath('//emit/xNome')&.text,
        enderEmit: {
          xLgr: doc.at_xpath('//emit/enderEmit/xLgr')&.text,
          nro: doc.at_xpath('//emit/enderEmit/nro')&.text,
          xBairro: doc.at_xpath('//emit/enderEmit/xBairro')&.text,
          xMun: doc.at_xpath('//emit/enderEmit/xMun')&.text,
          UF: doc.at_xpath('//emit/enderEmit/UF')&.text,
          CEP: doc.at_xpath('//emit/enderEmit/CEP')&.text,
          xPais: doc.at_xpath('//emit/enderEmit/xPais')&.text
        }
      },
      dest: {
        CNPJ: doc.at_xpath('//dest/CNPJ')&.text,
        xNome: doc.at_xpath('//dest/xNome')&.text,
        enderDest: {
          xLgr: doc.at_xpath('//dest/enderDest/xLgr')&.text,
          nro: doc.at_xpath('//dest/enderDest/nro')&.text,
          xBairro: doc.at_xpath('//dest/enderDest/xBairro')&.text,
          xMun: doc.at_xpath('//dest/enderDest/xMun')&.text,
          UF: doc.at_xpath('//dest/enderDest/UF')&.text,
          CEP: doc.at_xpath('//dest/enderDest/CEP')&.text,
          xPais: doc.at_xpath('//dest/enderDest/xPais')&.text
        }
      },
      produtos: doc.xpath('//det/prod').map do |prod|
        {
          xProd: prod.at_xpath('xProd')&.text,
          NCM: prod.at_xpath('NCM')&.text,
          CFOP: prod.at_xpath('CFOP')&.text,
          uCom: prod.at_xpath('uCom')&.text,
          qCom: prod.at_xpath('qCom')&.text.to_f,
          vUnCom: prod.at_xpath('vUnCom')&.text.to_f,
          vProd: prod.at_xpath('vProd')&.text.to_f
        }
      end,
      impostos: {
        ICMS: {
          vICMS: doc.at_xpath('//det/imposto/ICMS/ICMS00/vICMS')&.text.to_f,
          baseCalculo: doc.at_xpath('//det/imposto/ICMS/ICMS00/vBC')&.text.to_f,
          aliquota: doc.at_xpath('//det/imposto/ICMS/ICMS00/pICMS')&.text.to_f
        },
        IPI: {
          vIPI: doc.at_xpath('//det/imposto/IPI/IPITrib/vIPI')&.text.to_f
        },
        PIS: {
          vPIS: doc.at_xpath('//det/imposto/PIS/PISNT/CST')&.text # Se for necessário, adicione mais campos para o PIS
        },
        COFINS: {
          vCOFINS: doc.at_xpath('//det/imposto/COFINS/COFINSNT/CST')&.text # Se for necessário, adicione mais campos para o COFINS
        }
      },
      totalizadores: {
        total_produtos: doc.xpath('//det/prod/vProd').map { |vProd| vProd.text.to_f }.sum,
        total_impostos: [
          doc.at_xpath('//total/ICMSTot/vICMS')&.text.to_f,
          doc.at_xpath('//total/ICMSTot/vIPI')&.text.to_f,
          doc.at_xpath('//total/ICMSTot/vPIS')&.text.to_f,
          doc.at_xpath('//total/ICMSTot/vCOFINS')&.text.to_f
        ].sum
      }
    }
  end
  def generate_report(document_id, data)
    # Código para gerar e salvar o relatório
    report_content = <<-REPORT
      Relatório para o Documento ID: #{document_id}
      
      Dados do Documento Fiscal:
      Série: #{data[:serie]}
      Número da Nota Fiscal: #{data[:nNF]}
      Data e Hora de Emissão: #{data[:dhEmi]}
      Emitente: #{data[:emit][:xNome]} (CNPJ: #{data[:emit][:CNPJ]})
      Endereço do Emitente: #{data[:emit][:enderEmit][:xLgr]}, #{data[:emit][:enderEmit][:nro]}, #{data[:emit][:enderEmit][:xBairro]}, #{data[:emit][:enderEmit][:xMun]} - #{data[:emit][:enderEmit][:UF]}, CEP: #{data[:emit][:enderEmit][:CEP]}, País: #{data[:emit][:enderEmit][:xPais]}
      
      Destinatário: #{data[:dest][:xNome]} (CNPJ: #{data[:dest][:CNPJ]})
      Endereço do Destinatário: #{data[:dest][:enderDest][:xLgr]}, #{data[:dest][:enderDest][:nro]}, #{data[:dest][:enderDest][:xBairro]}, #{data[:dest][:enderDest][:xMun]} - #{data[:dest][:enderDest][:UF]}, CEP: #{data[:dest][:enderDest][:CEP]}, País: #{data[:dest][:enderDest][:xPais]}
      
      Produtos Listados:
      #{data[:produtos].map do |prod|
        "Nome: #{prod[:xProd]}, NCM: #{prod[:NCM]}, CFOP: #{prod[:CFOP]}, Unidade: #{prod[:uCom]}, Quantidade: #{prod[:qCom]}, Valor Unitário: #{prod[:vUnCom]}, Valor Total: #{prod[:vProd]}"
      end.join("\n")}
      
      Impostos Associados:
      ICMS: #{data[:impostos][:ICMS][:vICMS]}
      Base de Cálculo ICMS: #{data[:impostos][:ICMS][:baseCalculo]}
      Alíquota ICMS: #{data[:impostos][:ICMS][:aliquota]}
      IPI: #{data[:impostos][:IPI][:vIPI]}
      PIS: #{data[:impostos][:PIS][:vPIS]}
      COFINS: #{data[:impostos][:COFINS][:vCOFINS]}
      
      Total dos Produtos: #{data[:totalizadores][:total_produtos]}
      Total dos Impostos: #{data[:totalizadores][:total_impostos]}
    REPORT

    File.write(Rails.root.join('public', "relatorio_#{document_id}.txt"), report_content)
  end
end
