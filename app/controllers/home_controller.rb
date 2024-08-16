class HomeController < ApplicationController
  before_action :authenticate_user!

  def index
    @documents = current_user.documents
    @users = User.all
  end
end
