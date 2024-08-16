# db/migrate/20240814220055_add_foreign_key_to_documents.rb
class AddForeignKeyToDocuments < ActiveRecord::Migration[7.0]
  def change
    # Adiciona a chave estrangeira apenas se não existir
    unless foreign_key_exists?(:documents, :users)
      add_foreign_key :documents, :users
    end
  end
end