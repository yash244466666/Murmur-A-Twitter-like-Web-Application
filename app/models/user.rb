class User < ApplicationRecord
  has_secure_password

  # Relationships
  has_many :murmurs, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :liked_murmurs, through: :likes, source: :murmur
  
  # Following relationships
  has_many :active_follows, class_name: "Follow",
                           foreign_key: "follower_id",
                           dependent: :destroy
  has_many :passive_follows, class_name: "Follow",
                            foreign_key: "followed_id",
                            dependent: :destroy
  has_many :following, through: :active_follows, source: :followed
  has_many :followers, through: :passive_follows, source: :follower

  # Validations
  validates :username, presence: true, 
                      uniqueness: true, 
                      length: { minimum: 3, maximum: 30 },
                      format: { with: /\A[a-zA-Z0-9_]+\z/, message: "only allows letters, numbers and underscore" }
  validates :email, presence: true,
                   uniqueness: true,
                   format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, presence: true,
                      length: { minimum: 6 },
                      if: :password_required?
  validates :bio, length: { maximum: 160 }

  private

  def password_required?
    new_record? || password.present?
  end
end
