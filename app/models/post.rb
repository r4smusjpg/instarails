class Post < ApplicationRecord
  # relations
  belongs_to :user
  has_many :comments, dependent: :delete_all
  has_many :likes, dependent: :delete_all
  has_many_attached :images, dependent: :delete_all

  # scopes
  scope :with_user_with_attached_avatar,
        -> { includes(:user).merge(User.with_attached_avatar) }
  scope :with_attached_images, -> { includes(images_attachments: :blob) }
  scope :with_likes, -> { includes(:likes) }
  scope :with_comments_with_user_with_attached_avatar,
        -> { includes(:comments).merge(Comment.with_user_with_attached_avatar) }
  scope :by_created_at, ->(order) { order(created_at: order) }

  # validations
  validates :user_id, presence: true
  validates :content, length: { maximum: 200 }
  validates :images, attached: true,
                     content_type: %i[png jpg jpeg gif],
                     size: { less_than: 3.megabytes },
                     limit: { min: 1, max: 10 }
  
  # instance methods
  def created_at_formatted
    self.created_at.strftime("%d/%m/%Y at %H:%M")
  end

  def liked_by_user?(user)
    self.likes.find_by(user_id: user.id)
  end

  def like_by(user)
    self.likes << Like.new(post_id: self.id,
                           user_id: user.id)
  end

  def unlike_by(user)
    like = self.likes.find_by(user_id: user.id)
    self.likes.delete(like)
  end

  def liked_users
    User.where(id: self.likes.pluck(:user_id))
  end
end
