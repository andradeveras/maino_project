class AddDocumentToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :document_data, :text
  end
end
