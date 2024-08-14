class User < ApplicationRecord
  # Devise modules
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Validations
  validates :email, presence: true, uniqueness: true
  validates :password, presence: true, if: :password_required?

  def password_required?
    new_record? || password.present? || password_confirmation.present?
  end

  def admin?
    admin
  end
end
