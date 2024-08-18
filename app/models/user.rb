class User < ApplicationRecord
  has_many :documents
  
  include DocumentUploader::Attachment(:document) 

  
  # Devise modules
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Validations
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP, message: "não é um email válido" }
  validates :password, presence: true, if: :password_required?

  def password_required?
    new_record? || password.present? || password_confirmation.present?
  end

  def admin?
    admin
  end
end
