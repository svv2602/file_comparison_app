class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :projects, dependent: :destroy
  enum role: { admin: 'admin', regular: 'regular' }

  def admin?
    role == 'admin'
  end

  def can_edit_users?
    admin?
  end

  before_create :set_default_role

  private

  def set_default_role
    self.role ||= :regular
  end
end
