class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :authenticate_admin!, only: [:index, :show, :edit, :update, :destroy]
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  def index
    @users = User.all
  end

  def show
  end

  def edit
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to users_path, notice: 'Usuário criado com sucesso.'
    else
      render :new
    end
  end

  def update
    if @user.update(user_params)
      redirect_to @user, notice: 'Usuário foi atualizado com sucesso.'
    else
      render :edit
    end
  end

  def destroy
    @user.destroy
    redirect_to users_url, notice: 'Usuário foi deletado com sucesso.'
  end

  private

  def set_user
    @user = User.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: 'Usuário não encontrado.'
  end

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end

  def authenticate_admin!
    redirect_to root_path, alert: 'Não autorizado' unless current_user&.admin?
  end
end
