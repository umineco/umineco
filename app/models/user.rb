class User < ActiveRecord::Base
  has_many :members
  has_many :communities, through: :members
  has_many :feeds
  has_many :ships
  has_many :participants
  has_many :sailings, through: :participants
  has_many :comments

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable

  def self.find_for_facebook_oauth(auth)
    user = User.where(provider: auth.provider, uid: auth.uid).first
    unless user
      user = User.create(
        name:     auth.extra.raw_info.name,
        provider: auth.provider,
        uid:      auth.uid,
        email:    auth.info.email,
        token:    auth.credentials.token,
        password: Devise.friendly_token[0,20]
      )
    end
    return user
  end

  # type: enum { small, normal, album, large, square }
  # see: https://developers.facebook.com/docs/graph-api/reference/user/picture/
  def picture(type = :small)
    "https://graph.facebook.com/v2.5/#{uid}/picture?type=#{type.to_s}"
  end

end
