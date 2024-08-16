require "shrine"

class DocumentUploader < Shrine
  # Adicione plugins e opções necessárias aqui
  plugin :activerecord
  plugin :cached_attachment_data # Para restaurar o cache após um formulário ser re-renderizado
  plugin :restore_cached_data # Para restaurar metadados adicionais
  
  # Se você usa processamento, pode adicionar plugins e configurações adicionais aqui
  # plugin :processing
  # plugin :versions # Se você tiver várias versões de arquivos
  # plugin :mini_magick # Se você precisar processar imagens
end
