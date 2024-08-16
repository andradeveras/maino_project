class RemoveFileDataFromDocuments < ActiveRecord::Migration[7.1]
  def change
    remove_column :documents, :file_data, :text
  end
end
