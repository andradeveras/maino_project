require 'rails_helper'

RSpec.describe User, type: :model do
  it "is valid with a user_name and password" do
    user = User.new(
      email: "user@example.com",
      user_name: "Leonardo",
      password: "password123",
      password_confirmation: "password123"
    )
    expect(user).to be_valid
  end
end