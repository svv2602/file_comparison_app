class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  before_action :authorize_admin, only: [:index, :destroy]

  def index
    @users = User.all
  end

  def show
  end

  def new
    @user = User.new
  end

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to @user, notice: 'Профиль пользователя успешно обновлен.'
    else
      render :edit
    end
  end

  def destroy
    @user.destroy
    redirect_to users_url, notice: 'Пользователь успешно удален.'
  end

  def update_role
    if current_user.admin? # Проверяем, является ли текущий пользователь администратором
      user = User.find(params[:id])
      user.update(role: 'admin')
      redirect_to user
    else
      redirect_to root_path, alert: "У вас нет разрешения на выполнение этого действия."
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation, :role)
  end

  def authorize_admin
    redirect_to root_path, alert: 'У вас нет разрешения на выполнение этого действия.' unless current_user.admin?
  end
end
