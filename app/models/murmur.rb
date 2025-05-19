class Murmur < ApplicationRecord
  belongs_to :user
  has_many :likes, dependent: :destroy
  has_many :liked_by_users, through: :likes, source: :user

  validates :content, presence: true, length: { maximum: 280 }
  validates :user_id, presence: true

  default_scope -> { order(created_at: :desc) }

  def likes_count
    likes.count
  end
end
