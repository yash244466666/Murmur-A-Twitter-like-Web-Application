class Like < ApplicationRecord
  belongs_to :user
  belongs_to :murmur

  validates :user_id, presence: true
  validates :murmur_id, presence: true
  validates :user_id, uniqueness: { scope: :murmur_id }
end
