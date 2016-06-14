class Micropost < ActiveRecord::Base
  belongs_to :user
  validates :content, presence: true, length: {maximum: 140}
  validates :user_id, presence: true, allow_nil: false
  default_scope -> { order('created_at DESC')}
end
