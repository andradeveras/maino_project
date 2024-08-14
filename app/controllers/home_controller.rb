class HomeController < ApplicationController
  # Ação para exibir a página inicial
  def index
  end

  # Ação para exibir o formulário de criação de usuários
  def new
    @user = User.new
  end

  # Ação para criar um novo usuário
  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to root_path, notice: 'Usuário criado com sucesso.'
    else
      render :new
    end
  end

  private

  # Permitir apenas os parâmetros permitidos para criação de usuário
  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation, :admin)
  end
end
