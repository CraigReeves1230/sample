class User < ActiveRecord::Base

  # Associate with microposts
  has_many :microposts, dependent: :destroy

  # Attribute for remember token and email activation token
  attr_accessor :remember_token, :activation_token, :reset_token

  # Right before saving users to database, lowercase the email
  before_save :downcase_email

  # Before creating a user, give an authorization token and and digest in the databas
  before_create :create_activation_digest

  # This is a regular expression to determine email format
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  # Validation for names and emails
  validates :name, presence: true, length: {maximum: 50}
  validates :email, presence: true, length: {maximum: 250}, format: {with: VALID_EMAIL_REGEX}, uniqueness: {case_sensitive: false}

  # Password protection and validation
  has_secure_password
  validates :password, length: {maximum: 14, minimum: 5}, presence: true

  # Converts email to lowercase
  def downcase_email
    self.email = email.downcase
  end

  # Creates and assigns the activation token and digest
  def create_activation_digest
    self.activation_token = User.new_token
    self.activation_digest = User.digest(activation_token)
  end

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

  # activates a user
  def activate
    update_attribute(:activated, true)
    update_attribute(:activated_at, Time.zone.now)
  end

  # sends activation email
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  # Returns true if the given token matches the digest
  def authenticated?(attribute = "remember", token)
    # determine what kind of token it is
    digest = send("#{attribute}_digest")
    # Prevent problems with logging out in one browser but staying logged in in another
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  # Creates a reset password digest from a reset token
  def create_reset_digest
    self.reset_token = User.new_token
    update_attribute(:reset_digest, User.digest(reset_token))
    update_attribute(:reset_sent_at, Time.zone.now)
  end

  # Sends password reset email
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  # Returns true if a password reset link expired
  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end

end
