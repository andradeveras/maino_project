# spec/factories/documents.rb

FactoryBot.define do
  factory :document do
    user
    serie { "123" }
    nNF { "456" }
    dhEmi { Time.now }
    emit_name { "Empresa Teste" }
    dest_name { "Cliente Teste" }
    prod_xProd { "Produto Teste" }
    prod_NCM { "12345678" }
    prod_CFOP { "5102" }
    prod_uCom { "UN" }
    prod_qCom { 10 }
    prod_vUnCom { 50.0 }
    imposto_vICMS { 5.0 }
    imposto_vIPI { 2.0 }
    imposto_vPIS { 1.0 }
    imposto_vCOFINS { 1.5 }
    total_vProd { 500.0 }
    total_vICMS { 5.0 }
    total_vIPI { 2.0 }
    total_vPIS { 1.0 }
    total_vCOFINS { 1.5 }
    file_data { Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/files/sample.xml'), 'text/xml') }
  end
end
