# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
#
# Create test users
puts "Creating users..."
user1 = User.create!(
  username: "john_doe",
  email: "john@example.com",
  password: "password123",
  bio: "Just a regular guy tweeting about life"
)

user2 = User.create!(
  username: "jane_smith",
  email: "jane@example.com",
  password: "password123",
  bio: "Tech enthusiast and coffee lover"
)

user3 = User.create!(
  username: "bob_wilson",
  email: "bob@example.com",
  password: "password123",
  bio: "Professional cloud watcher"
)

# Create some murmurs
puts "Creating murmurs..."
murmur1 = user1.murmurs.create!(
  content: "Hello world! This is my first murmur!"
)

murmur2 = user2.murmurs.create!(
  content: "Just learned something new about Ruby on Rails!"
)

murmur3 = user3.murmurs.create!(
  content: "Beautiful day for coding!"
)

# Create follow relationships
puts "Creating follow relationships..."
user1.active_follows.create!(followed: user2)
user2.active_follows.create!(followed: user3)
user3.active_follows.create!(followed: user1)

# Create some likes
puts "Creating likes..."
user1.likes.create!(murmur: murmur2)
user2.likes.create!(murmur: murmur3)
user3.likes.create!(murmur: murmur1)

puts "Seed data created successfully!"
