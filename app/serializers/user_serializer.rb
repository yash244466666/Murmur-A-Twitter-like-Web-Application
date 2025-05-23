class UserSerializer
  def initialize(user)
    @user = user
  end

  def as_json(*)
    {
      id: @user.id,
      username: @user.username,
      email: @user.email,
      bio: @user.bio,
      created_at: @user.created_at
    }
  end
end
