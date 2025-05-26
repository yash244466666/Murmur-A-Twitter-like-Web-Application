class Follow < ApplicationRecord
  belongs_to :follower, class_name: "User"
  belongs_to :followed, class_name: "User"

  validates :follower_id, presence: true
  validates :followed_id, presence: true
  validates :follower_id, uniqueness: { scope: :followed_id }
  validate :not_following_self

  private

  def not_following_self
    errors.add(:follower_id, "can't follow yourself") if follower_id == followed_id
  end
end
