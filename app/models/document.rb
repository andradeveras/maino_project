class Document < ApplicationRecord
  belongs_to :user
  include DocumentUploader::Attachment(:file)
  validates :file_data, presence: true
end
