class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :projects
  enum role: { admin: 'admin', regular: 'regular' }

  def admin?
    role == 'admin'
  end
  def can_edit_users?
    admin? # Метод, определяющий, может ли пользователь с ролью "admin" редактировать других пользователей
  end

end
