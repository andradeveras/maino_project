class DocumentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_document, only: %i[show download_excel destroy]
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
      @data = parse_xml(xml_content)
    else
      @data = {}
    end
  end

  def index
    @documents = current_user.documents

    if params[:search].present?
      @documents = @documents.where("serie LIKE :search OR nNF LIKE :search OR dhEmi LIKE :search",
                                    search: "%#{params[:search]}%")
    end
  end
  
  def destroy
    if @document.user == current_user
      @document.destroy
      redirect_to documents_path, notice: 'Documento excluído com sucesso.'
    else
      redirect_to documents_path, alert: 'Você não tem permissão para excluir este documento.'
    end
  end



  def download_excel
    excel_content = ExcelReportService.new(@document).generate

    send_data excel_content, filename: "relatorio_documento_#{Time.now.to_i}.xlsx", type: "application/xlsx"
  end
  
  private

  def set_document
    @document = Document.find(params[:id])
  end

  def document_params
    params.require(:document).permit(:file)
  end

  def document_attributes(document)
    {
      id: document.id,
      serie: document.serie,
      nNF: document.nNF,
      dhEmi: document.dhEmi,
      # Inclua outros atributos que deseja expor no JSON
    }
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
end
