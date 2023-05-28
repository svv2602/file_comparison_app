class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  before_action :authorize_admin, only: [:index, :destroy, :edit, :update]


  def index
    @users = User.all
  end

  def show
  end



  def edit
    if current_user.can_edit_users? || current_user == @user
      render :edit
    else
      flash[:danger] = "У вас нет разрешения на выполнение этого действия."
      redirect_to root_path
    end
  end


  def update
    if @user.update(user_params)
      flash[:success] = 'Профиль пользователя успешно обновлен.'
      redirect_to @user
    else
      render :edit
    end
  end

  def destroy
    @user = User.find(params[:id])
    @user.projects.destroy_all # Удаление связанных проектов пользователя

    @user.destroy
    flash[:warning] = 'Пользователь успешно удален.'
    redirect_to users_url
  end

  def update_role
    if current_user.admin? # Проверяем, является ли текущий пользователь администратором
      user = User.find(params[:id])
      if !user.admin?
        user.update(role: 'admin')
      else
        user.update(role: 'regular')
      end

      redirect_to user
    else
      flash[:danger] = "У вас нет разрешения на выполнение этого действия."
      redirect_to root_path
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
    flash[:danger] = "У вас нет разрешения на выполнение этого действия."
    redirect_to root_path unless current_user.admin?
    # redirect_to root_path, alert: 'У вас нет разрешения на выполнение этого действия.' unless current_user.admin?
  end
end
