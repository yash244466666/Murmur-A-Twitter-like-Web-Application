# Twitter Clone API

A Ruby on Rails API for a Twitter-like social media platform with features like murmurs (tweets), follows, and likes.

## Technologies Used

- Ruby 3.4.0
- Rails 8.0.2
- MySQL
- JWT for authentication
- Rack CORS for handling cross-origin requests

## Setup

1. Clone the repository
2. Install dependencies:
   ```bash
   bundle install
   ```
3. Set up the database:
   ```bash
   rails db:create db:migrate db:seed
   ```
4. Start the server:
   ```bash
   rails server
   ```

## API Documentation

All API endpoints except registration and login require authentication. Include the JWT token in the Authorization header:

```
Authorization: Bearer your-jwt-token
```

### Authentication

#### Register New User
```http
POST /users
Content-Type: application/json

{
  "username": "johndoe",
  "email": "john@example.com",
  "password": "password123",
  "bio": "Hello, I'm John!"
}

Response (201 Created):
{
  "user": {
    "id": 1,
    "username": "johndoe",
    "email": "john@example.com",
    "bio": "Hello, I'm John!",
    "created_at": "2025-05-20T10:00:00Z"
  }
}
```

#### Login
```http
POST /auth/login
Content-Type: application/json

{
  "email": "john@example.com",
  "password": "password123"
}

Response (200 OK):
{
  "token": "your-jwt-token",
  "user": {
    "id": 1,
    "username": "johndoe",
    "email": "john@example.com",
    "bio": "Hello, I'm John!",
    "created_at": "2025-05-20T10:00:00Z"
  }
}
```

### Murmurs (Tweets)

#### Get All Murmurs
```http
GET /api/murmurs

Response (200 OK):
{
  "murmurs": [
    {
      "id": 1,
      "content": "Hello world!",
      "created_at": "2025-05-20T10:00:00Z",
      "user": {
        "id": 1,
        "username": "johndoe",
        "bio": "Hello, I'm John!"
      },
      "likes_count": 5,
      "liked_by_current_user": true
    }
  ]
}
```

#### Create Murmur
```http
POST /api/murmurs
Content-Type: application/json

{
  "content": "This is my first murmur!"
}

Response (201 Created):
{
  "id": 2,
  "content": "This is my first murmur!",
  "created_at": "2025-05-20T10:30:00Z",
  "user": {
    "id": 1,
    "username": "johndoe",
    "bio": "Hello, I'm John!"
  },
  "likes_count": 0,
  "liked_by_current_user": false
}
```

#### Get Personal Timeline
```http
GET /api/timeline

Response (200 OK):
{
  "murmurs": [
    {
      "id": 1,
      "content": "Hello world!",
      "created_at": "2025-05-20T10:00:00Z",
      "user": {
        "id": 1,
        "username": "johndoe",
        "bio": "Hello, I'm John!"
      },
      "likes_count": 5,
      "liked_by_current_user": true
    }
  ]
}
```

### Follows

#### Follow User
```http
POST /api/follows
Content-Type: application/json

{
  "followed_id": 2
}

Response (201 Created):
{
  "message": "Following successfully"
}
```

#### Unfollow User
```http
DELETE /api/follows/2

Response (204 No Content)
```

### Likes

#### Like Murmur
```http
POST /api/likes
Content-Type: application/json

{
  "murmur_id": 1
}

Response (201 Created):
{
  "message": "Liked successfully"
}
```

#### Unlike Murmur
```http
DELETE /api/likes/1

Response (204 No Content)
```

### User Profile

#### Get User Profile
```http
GET /api/profile/johndoe

Response (200 OK):
{
  "user": {
    "id": 1,
    "username": "johndoe",
    "email": "john@example.com",
    "bio": "Hello, I'm John!",
    "created_at": "2025-05-20T10:00:00Z"
  },
  "murmurs_count": 10,
  "followers_count": 5,
  "following_count": 8,
  "is_following": true,
  "murmurs": [
    {
      "id": 1,
      "content": "Hello world!",
      "created_at": "2025-05-20T10:00:00Z",
      "likes_count": 5,
      "liked_by_current_user": true
    }
  ]
}
```

## Error Responses

The API returns appropriate HTTP status codes and error messages:

```http
401 Unauthorized:
{
  "error": "Unauthorized"
}

404 Not Found:
{
  "error": "Resource not found"
}

422 Unprocessable Entity:
{
  "errors": ["Error message 1", "Error message 2"]
}
```
