class AddFileDataToDocuments < ActiveRecord::Migration[7.1]
  def change
    add_column :documents, :file_data, :text
  end
end
