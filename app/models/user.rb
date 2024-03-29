class User < ApplicationRecord
  has_secure_password

  # relations
  has_many :comments, dependent: :delete_all
  has_many :posts, dependent: :delete_all
  has_one_attached :avatar, dependent: :destroy
  has_many :active_relationships, class_name: 'Relationship',
                                  foreign_key: 'follower_id',
                                  dependent: :destroy
  has_many :followings, through: :active_relationships,
                        source: :followed

  has_many :passive_relationships, class_name: 'Relationship',
                                   foreign_key: 'followed_id',
                                   dependent: :destroy
  has_many :followers, through: :passive_relationships,
                       source: :follower

  # scopes
  scope :by_created_at, ->(order) { order(created_at: order) }
  scope :with_attached_avatar, -> { includes(avatar_attachment: :blob) }

  # callbacks
  before_save { self.email.downcase! }

  # validations
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i

  validates :email, presence: true,
                    format: { with: VALID_EMAIL_REGEX },
                    length: { in: 5..70 },
                    uniqueness: true

  validates :nickname, presence: true,
                       length: { in: 3..40 },
                       uniqueness: true

  validates :biography, length: { maximum: 300 }

  validates :avatar, content_type: %i[png jpg jpeg gif],
                     size: { less_than: 5.megabytes },
                     limit: { max: 1 }

  validates :full_name, presence: true,
                        length: { in: 3..50 }

  # presence validation for password is not necessary
  # because has_secure_password automatically adds it
  validates :password, length: { in: 8..60 }

  validates :password_confirmation, presence: true,
                                    length: { in: 8..60 }
  # instance methods
  def delete_avatar
    self.avatar.purge
  end

  def follow(other_user)
    self.followings << other_user
  end

  def unfollow(other_user)
    self.followings.delete(other_user)
  end

  def following?(other_user)
    self.followings.include?(other_user)
  end

  def feed
    Post.with_user_with_attached_avatar
        .with_comments_with_user_with_attached_avatar
        .where(user_id: self.followings.ids)
        .by_created_at(:desc)
  end
end
