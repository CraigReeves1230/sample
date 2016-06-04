class User < ActiveRecord::Base

  # Attribute for remember token
  attr_accessor :remember_token

  # Right before saving users to database, lowercase the email
  before_save { self.email = self.email.downcase }

  # This is a regular expression to determine email format
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  # Validation for names and emails
  validates :name, presence: true, length: {maximum: 50}
  validates :email, presence: true, length: {maximum: 250}, format: {with: VALID_EMAIL_REGEX}, uniqueness: {case_sensitive: false}

  # Password protection and validation
  has_secure_password
  validates :password, length: {maximum: 14, minimum: 5}, presence: true

  # Returns the hash digest of the given string
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  # method to generate a remember token which is a random string of 22 characters
  def User.new_token
    SecureRandom.urlsafe_base64
  end

  # remember user with remember token
  def remember
    self.remember_token = User.new_token  # create new token and assign it to remember token
    # update the remember_digest in the database with a B-Crypt hash digest of the remember token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  # forgets user by erasing remember digest from database table
  def forget
    update_attribute(:remember_digest, nil)
  end

  # Returns true if the given token matches the digest
  def authenticated?(remember_token)
    # Prevent problems with logging out in one browser but staying logged in in another
    return false if remember_digest.nil?
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

end
