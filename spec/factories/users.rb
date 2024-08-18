FactoryBot.define do
  factory :user do
    # Atributos necessários para criar um usuário
    email { "user@example.com" }
    password { "password" }
  end
end