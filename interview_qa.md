# Murmur (Twitter Clone) Application - Technical Interview Q&A

## 1. Architecture & Design

**Q: Why did you choose to implement JWT for API authentication but session-based authentication for web interface? What are the trade-offs?**

A: The dual authentication approach was chosen for optimal user experience and security:

```ruby
# API Authentication (JWT)
if request.format.json?
  token = JsonWebToken.encode(user_id: @user.id)
  render json: {
    token: token,
    user: UserSerializer.new(@user)
  }
else
  # Web Authentication (Sessions)
  session[:user_id] = @user.id
  redirect_to root_path
end
```

Benefits:
- JWT for API:
  - Stateless authentication
  - Ideal for mobile/external clients
  - Easy to scale horizontally
  - No session storage needed
  
- Sessions for Web:
  - Better security for browser users
  - Built-in CSRF protection
  - Easier to invalidate
  - More memory-efficient for web-only users

**Q: How did you optimize the timeline query performance?**

A: Several optimization techniques were implemented:

```ruby
# In MurmursController
def timeline
  following_ids = current_user.following.pluck(:id)
  @murmurs = Murmur.includes(:user, :likes)
                   .where(user_id: following_ids + [current_user.id])
                   .order(created_at: :desc)
                   .page(params[:page])
                   .per(10)
end
```

Optimizations:
- Eager loading with includes(:user, :likes) to prevent N+1 queries
- Pagination to limit result set
- Proper indexing on user_id and created_at
- Composite indexes for frequent queries

## 2. Database Design

**Q: Explain the follows table structure, indexes, and prevention of self-following**

A: The follows table implementation:

```ruby
# Migration
create_table "follows" do |t|
  t.bigint "follower_id"
  t.bigint "followed_id"
  t.index ["followed_id"]
  t.index ["follower_id", "followed_id"], unique: true
  t.index ["follower_id"]
end

# Model
class Follow < ApplicationRecord
  belongs_to :follower, class_name: "User"
  belongs_to :followed, class_name: "User"
  
  validate :cannot_follow_self
  
  private
  
  def cannot_follow_self
    errors.add(:base, "Cannot follow yourself") if follower_id == followed_id
  end
end
```

Key points:
- Self-referential relationship using follower_id and followed_id
- Composite unique index prevents duplicate follows
- Model validation prevents self-following
- Proper indexes for efficient querying

## 3. Modern Rails Features

**Q: Explain the choice of importmap-rails and jsbundling-rails over Webpack**

A: Modern Rails asset handling:

```ruby
# config/importmap.rb
pin "@hotwired/turbo-rails"
pin "@hotwired/stimulus"
pin "toastify-js"

# package.json
{
  "dependencies": {
    "@hotwired/stimulus": "^3.2.2",
    "@hotwired/turbo-rails": "^7.3.0",
    "toastify-js": "^1.12.0"
  }
}
```

Benefits:
- Native ES modules support
- No build step in development
- Faster development cycle
- Still allows npm packages when needed
- Better integration with Rails
- Simpler dependency management

## 4. API Design

**Q: How do you handle authentication, response formats, and errors across interfaces?**

A: Consistent handling through base controller:

```ruby
class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  
  def authenticate_user!
    if request.format.json?
      # JWT Authentication
      token = request.headers['Authorization']&.split&.last
      @current_user = User.find(JsonWebToken.decode(token)[:user_id])
    else
      # Session Authentication
      @current_user = User.find_by(id: session[:user_id])
    end
    
    handle_unauthorized unless @current_user
  end

  private

  def handle_unauthorized
    respond_to do |format|
      format.html { redirect_to login_path, alert: 'Please log in.' }
      format.json { render json: { error: 'Unauthorized' }, status: :unauthorized }
    end
  end
end
```

Features:
- Unified authentication flow
- Format-specific responses
- Consistent error handling
- Clean separation of concerns

## 5. Security

**Q: Explain JWT implementation, security measures, and authorization**

A: Comprehensive security approach:

```ruby
# lib/json_web_token.rb
class JsonWebToken
  SECRET_KEY = Rails.application.credentials.secret_key_base
  
  def self.encode(payload)
    payload.reverse_merge!(exp: 24.hours.from_now.to_i)
    JWT.encode(payload, SECRET_KEY)
  end
  
  def self.decode(token)
    JWT.decode(token, SECRET_KEY).first
  rescue
    nil
  end
end

# Security Headers
config.action_dispatch.default_headers = {
  'X-Frame-Options' => 'SAMEORIGIN',
  'X-XSS-Protection' => '1; mode=block',
  'X-Content-Type-Options' => 'nosniff'
}
```

Security measures:
- JWT expiration
- Secure token storage
- XSS protection
- CSRF protection
- HTTP-only cookies
- Content Security Policy

## 6. Performance & Scaling

**Q: How would you handle timeline performance at scale?**

A: Multi-layered optimization strategy:

```ruby
# Current Implementation
def timeline
  @murmurs = Murmur.includes(:user, :likes)
                   .where(user_id: following_ids + [current_user.id])
                   .order(created_at: :desc)
                   .page(params[:page])
                   .per(10)
end

# Potential Enhancements
# 1. Redis Caching
Rails.cache.fetch("user_#{current_user.id}_timeline_page_#{params[:page]}", expires_in: 5.minutes) do
  timeline_query
end

# 2. Background Processing
TimelineGeneratorJob.perform_later(user_id: current_user.id)

# 3. Materialized Views
CREATE MATERIALIZED VIEW user_timeline AS
SELECT murmurs.* FROM murmurs
INNER JOIN follows ON murmurs.user_id = follows.followed_id
```

Scaling strategies:
- Redis caching
- Background jobs
- Database optimization
- Query tuning
- Materialized views
- Load balancing

## 7. Testing

**Q: Explain your testing strategy**

A: Comprehensive testing approach:

```ruby
# spec/requests/murmurs_spec.rb
RSpec.describe "Murmurs", type: :request do
  let(:user) { create(:user) }
  let(:token) { JsonWebToken.encode(user_id: user.id) }
  
  describe "GET /api/timeline" do
    before do
      create_list(:murmur, 3, user: user)
    end
    
    it "returns user's timeline" do
      get "/api/timeline", 
          headers: { 'Authorization': "Bearer #{token}" }
      
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)['murmurs'].length).to eq(3)
    end
  end
end

# spec/models/follow_spec.rb
RSpec.describe Follow, type: :model do
  it "prevents self-following" do
    user = create(:user)
    follow = build(:follow, follower: user, followed: user)
    expect(follow).not_to be_valid
  end
end
```

Testing coverage:
- Unit tests
- Integration tests
- API tests with RSwag
- Factory Bot for test data
- Comprehensive model specs
- Controller specs
- Request specs

## 8. Frontend Implementation

**Q: Explain Stimulus JS and Hotwire implementation**

A: Modern frontend architecture:

```javascript
// app/javascript/controllers/notification_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.element.style.opacity = '0'
    this.show()
  }
  
  show() {
    this.element.style.opacity = '1'
    if (this.hasAutohideValue) {
      setTimeout(() => this.close(), this.durationValue)
    }
  }
  
  close() {
    this.element.style.opacity = '0'
    setTimeout(() => this.element.remove(), 300)
  }
}
```

Features:
- Stimulus controllers for UI logic
- Turbo Drive for navigation
- Turbo Frames for partial updates
- Turbo Streams for real-time
- Toast notifications system

## 9. Code Quality & Maintenance

**Q: Explain your approach to code quality**

A: Multi-faceted quality assurance:

```ruby
# .rubocop.yml
require:
  - rubocop-rails
  - rubocop-rspec

AllCops:
  NewCops: enable
  TargetRubyVersion: 3.4.3

# brakeman.yml
:min_confidence: 2
:output_files:
  - tmp/brakeman.html
```

Quality measures:
- RuboCop for style
- Brakeman for security
- RSpec for testing
- Code review process
- Documentation standards
- CI/CD pipeline

## 10. Infrastructure

**Q: Explain your deployment and infrastructure setup**

A: Docker-based deployment:

```dockerfile
# Dockerfile
FROM ruby:3.4.3-alpine

# Multi-stage build for assets
FROM node:16-alpine AS assets
COPY --from=builder /app/public /public

# Production image
FROM ruby:3.4.3-alpine
COPY --from=assets /public /app/public

# Health check
HEALTHCHECK CMD curl -f http://localhost:3000/up || exit 1
```

Infrastructure features:
- Docker containerization
- Multi-stage builds
- Health checks
- Zero-downtime deploys
- Database migrations
- Asset compilation

## 11. Future Enhancements

**Q: What would you add to make this production-ready?**

A: Key enhancements:

1. Search Implementation:
```ruby
class Murmur < ApplicationRecord
  include Searchable
  
  searchable do
    text :content
    text :user do
      user.username
    end
    time :created_at
  end
end
```

2. Media Handling:
```ruby
class Murmur < ApplicationRecord
  has_one_attached :media
  
  validates :media,
    content_type: ['image/png', 'image/jpeg', 'video/mp4'],
    size: { less_than: 100.megabytes }
end
```

3. Real-time Updates:
```ruby
# app/channels/timeline_channel.rb
class TimelineChannel < ApplicationCable::Channel
  def subscribed
    stream_from "user_#{current_user.id}_timeline"
  end
end
```

Planned features:
- Elasticsearch integration
- Active Storage for media
- Action Cable for real-time
- Background jobs with Sidekiq
- Advanced caching
- Monitoring and logging
- Admin interface

---

## Key Takeaways

1. **Architecture**
   - Dual authentication strategy
   - Optimized queries
   - Scalable design

2. **Technology Choices**
   - Modern Rails features
   - Current best practices
   - Future-proof decisions

3. **Quality & Security**
   - Comprehensive testing
   - Security measures
   - Code quality tools

4. **Performance**
   - Query optimization
   - Caching strategy
   - Scaling considerations

5. **Future-Ready**
   - Clear upgrade path
   - Scalability options
   - Enhancement opportunities
