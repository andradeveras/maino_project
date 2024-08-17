# app/services/excel_report_service.rb

require 'caxlsx'

class ExcelReportService
  def initialize(document)
    @document = document
  end

  def generate
    xml_content = @document.file.download
    data = parse_xml(xml_content)

    package = Axlsx::Package.new
    workbook = package.workbook

    workbook.add_worksheet(name: "Documento Fiscal") do |sheet|
      # Dados do Documento Fiscal
      sheet.add_row ["Dados do Documento Fiscal"]
      sheet.add_row ["Série", data[:serie]]
      sheet.add_row ["Número da Nota Fiscal", data[:nNF]]
      sheet.add_row ["Data e Hora de Emissão", data[:dhEmi]]

      # Emitente
      sheet.add_row ["Emitente"]
      sheet.add_row ["CNPJ", data[:emit][:CNPJ]]
      sheet.add_row ["Nome", data[:emit][:xNome]]
      sheet.add_row ["Endereço"]
      sheet.add_row ["Logradouro", data[:emit][:enderEmit][:xLgr]]
      sheet.add_row ["Número", data[:emit][:enderEmit][:nro]]
      sheet.add_row ["Bairro", data[:emit][:enderEmit][:xBairro]]
      sheet.add_row ["Cidade", data[:emit][:enderEmit][:xMun]]
      sheet.add_row ["Estado", data[:emit][:enderEmit][:UF]]
      sheet.add_row ["CEP", data[:emit][:enderEmit][:CEP]]
      sheet.add_row ["País", data[:emit][:enderEmit][:xPais]]

      # Destinatário
      sheet.add_row ["Destinatário"]
      sheet.add_row ["CNPJ", data[:dest][:CNPJ]]
      sheet.add_row ["Nome", data[:dest][:xNome]]
      sheet.add_row ["Endereço"]
      sheet.add_row ["Logradouro", data[:dest][:enderDest][:xLgr]]
      sheet.add_row ["Número", data[:dest][:enderDest][:nro]]
      sheet.add_row ["Bairro", data[:dest][:enderDest][:xBairro]]
      sheet.add_row ["Cidade", data[:dest][:enderDest][:xMun]]
      sheet.add_row ["Estado", data[:dest][:enderDest][:UF]]
      sheet.add_row ["CEP", data[:dest][:enderDest][:CEP]]
      sheet.add_row ["País", data[:dest][:enderDest][:xPais]]

      # Produtos
      sheet.add_row ["Produtos"]
      sheet.add_row ["Nome", "NCM", "CFOP", "Unidade", "Quantidade", "Valor Unitário", "Valor Total"]
      data[:produtos].each do |produto|
        sheet.add_row [produto[:xProd], produto[:NCM], produto[:CFOP], produto[:uCom], produto[:qCom], produto[:vUnCom], produto[:vProd]]
      end

      # Impostos
      sheet.add_row ["Impostos"]
      sheet.add_row ["ICMS", data[:impostos][:ICMS][:vICMS]]
      sheet.add_row ["Base de Cálculo ICMS", data[:impostos][:ICMS][:baseCalculo]]
      sheet.add_row ["Alíquota ICMS", data[:impostos][:ICMS][:aliquota]]
      sheet.add_row ["IPI", data[:impostos][:IPI][:vIPI]]
      sheet.add_row ["PIS", data[:impostos][:PIS][:vPIS]]
      sheet.add_row ["COFINS", data[:impostos][:COFINS][:vCOFINS]]

      # Totalizadores
      sheet.add_row ["Totalizadores"]
      sheet.add_row ["Total Produtos", data[:totalizadores][:total_produtos]]
      sheet.add_row ["Total Impostos", data[:totalizadores][:total_impostos]]
    end

    package.to_stream.read
  end

  private

  def parse_xml(xml_content)
    doc = Nokogiri::XML(xml_content)
    doc.remove_namespaces!

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
          vPIS: doc.at_xpath('//det/imposto/PIS/PISNT/CST')&.text
        },
        COFINS: {
          vCOFINS: doc.at_xpath('//det/imposto/COFINS/COFINSNT/CST')&.text
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
