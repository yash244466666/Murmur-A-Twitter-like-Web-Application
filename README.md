# Murmur: A Twitter-like Web Application

This project, "Murmur", is a web application similar to Twitter/X, allowing users to post "murmurs" (tweets), follow other users, and like murmurs. It has been developed as a coding test for a Ruby/Rails engineer position.

## Project Status (as of May 20, 2025)

This project fulfills most of the core requirements outlined in the coding test instructions. Key features like user authentication, posting murmurs, following/unfollowing users, liking/unliking murmurs, user profiles, and a personal timeline are implemented for both a web interface and a JSON API.

## Project Demo Video

A short video demonstrating the application's features can be found here:
[Murmur App Video Demo](https://drive.google.com/file/d/1cYm_koJCKZnLN1qmPIPMmfH05rHXXozV/view?usp=sharing)

## Application Screenshot

![Murmur App Screenshot](Screenshot%20from%202025-05-20%2023-40-04.png)

## Original Requirements Summary

The goal was to implement a web application with the following specifications:

**Core Functionality:**
- Users can follow other users.
- A timeline displays murmurs from followed users.
- Users can post murmurs.
- Only the user who posted can delete their murmur.
- Users can LIKE another person's murmur.
- [Optional] User authentication.

**Technical Stack:**
- Ruby 3.x or later
- Ruby on Rails 4.x or later
- MySQL
- Webpack
- Tailwind CSS

**DB:**
- Use `murmurs` and `users` tables, add columns as needed.
- Add more tables as necessary (e.g., for follows, likes).

**Server (REST API):**
- Implement RESTful API endpoints. Examples provided:
  - `[GET] /api/murmurs/`
  - `[POST] /api/me/murmurs/`
  - `[DELETE] /api/me/murmurs/:id/`

**Client (Web Interface):**
- **Timeline:** List murmurs (text, LIKE count), LIKE button, pagination (10 murmurs/page).
- **Murmur Detail:** Show murmur information.
- **Own User Detail:** User info (name, follow/followed count), list of own murmurs, delete button for own murmurs.
- **Other User Detail:** User info, list of their murmurs.

## Implemented Features & How Requirements Were Met

**1. Core Functionality:**
   - **User Follows:** Implemented (`Follow` model, `FollowsController`). Users can follow/unfollow. **(✓ Met)**
   - **Timeline:** Implemented (`MurmursController#timeline`). Displays murmurs from followed users and the current user's own murmurs, paginated. **(✓ Met)**
   - **Post Murmurs:** Implemented (`Murmur` model, `MurmursController`). Users can create murmurs. **(✓ Met)**
   - **Delete Own Murmur:** Implemented (`MurmursController#destroy` with `check_murmur_owner` authorization). **(✓ Met)**
   - **Like Murmurs:** Implemented (`Like` model, `LikesController`). Users can like/unlike murmurs. **(✓ Met)**
   - **User Authentication:** Implemented for both web (sessions) and API (JWT). (`AuthenticationController`, `JsonWebToken` lib). **(✓ Met - Optional requirement completed)**

**2. Technical Stack:**
   - **Ruby:** Project uses Ruby 3.4.3.
   - **Ruby on Rails:** Project uses Rails 8.0.2. **(✓ Met)**
   - **Database:** Currently uses **MySQL**. The requirement was **MySQL**. **(✓ Met)**
   - **JavaScript Bundling (Webpack):** Uses `importmap-rails` and `jsbundling-rails` (with esbuild), which are the modern Rails standards for JavaScript management, fulfilling the intent of using a JS bundler. **(✓ Met, via modern Rails equivalents)**
   - **Tailwind CSS:** Implemented and used for styling. **(✓ Met)**

**3. Database Structure:**
   - `users` table: Includes `username`, `email`, `password_digest`, `bio`.
   - `murmurs` table: Includes `content`, `user_id`.
   - Additional tables: `follows` and `likes` created to manage relationships.
   - **(✓ Met)**

**4. Server (REST API):**
   - A comprehensive JSON API is implemented, covering authentication, users, murmurs, follows, and likes.
   - API documentation is available via Swagger/Rswag.
   - **(✓ Met and Exceeded)**

**5. Client (Web Interface):**
   - **Timeline:** Implemented at `/` (root) and `/timeline`. Shows murmurs with content, user info, like counts, like/unlike buttons, and pagination (10 per page via Kaminari). **(✓ Met)**
   - **Murmur Detail:** A specific detail page for a single murmur (`MurmursController#show`) is available, though direct linking from the timeline might not be explicitly implemented. Data is available via API. **(Partially Met - Backend exists, UI linking can be enhanced)**
   - **Own User Detail (`/@username`):** Displays user info (username, bio, follower/following counts), lists own murmurs with like counts and delete buttons (if owner). **(✓ Met)**
   - **Other User Detail (`/@username`):** Displays user info, lists their murmurs with like counts. **(✓ Met)**
   - **Notifications:** Implemented using Toastify JS via a Stimulus controller (`toast_controller.js`) for flash messages, and a custom Stimulus controller (`notification_controller.js`) was also developed for more animated notifications (though `toast_controller.js` is the primary one for flash messages).

## Technologies Used in This Project

- **Backend:** Ruby 3.4.3, Rails 8.0.2
- **Database:** MySQL
- **Frontend:**
    - HTML (ERB)
    - Tailwind CSS
    - JavaScript (ES6+)
    - Stimulus JS
    - Hotwire/Turbo (implied)
    - Toastify JS (for notifications)
    - `importmap-rails` for JS module management
    - `jsbundling-rails` (with esbuild) for JS bundling
- **API Documentation:** Rswag (Swagger)
- **Authentication:** Custom JWT for API, Rails sessions for Web
- **Pagination:** Kaminari gem
- **Testing:** RSpec, FactoryBot
- **Containerization:** Docker, Docker Compose
- **Linters/Formatters:** RuboCop, Brakeman (security scanner)

## Setup and Installation

1.  **Clone the repository:**
    ```bash
    git clone <repository-url>
    cd ti
    ```
2.  **Install Ruby and Node.js:** Ensure you have Ruby (3.4.3) and Node.js (>= 16.x) installed.
3.  **Install dependencies:**
    ```bash
    bundle install
    yarn install # If you have package.json dependencies not managed by importmaps directly
    ```
4.  **Database Setup (MySQL):**
    *   Ensure MySQL server is running.
    *   Create a user/role in MySQL that matches your `config/database.yml` development settings (or update `database.yml`).
    *   Create the database, run migrations, and seed data:
        ```bash
        rails db:create
        rails db:migrate
        rails db:seed
        ```
5.  **Start the development server:**
    ```bash
    bin/dev
    ```
    This will typically start the Rails server and the JavaScript/CSS build processes.
    The application should be available at `http://localhost:3000`.

## Key Page Links

- **Timeline (Root):** `http://localhost:3000/`
- **Sign Up:** `http://localhost:3000/signup`
- **Login:** `http://localhost:3000/login`
- **User Profile:** `http://localhost:3000/@username` (e.g., `http://localhost:3000/@johndoe`)

## API Documentation

API documentation is generated using Rswag and is available when the application is running:

- **Swagger UI:** `http://localhost:3000/api-docs`

All API endpoints (except user registration and login) require a JWT token in the `Authorization` header:
`Authorization: Bearer <your-jwt-token>`

### Main API Endpoints

(Refer to the `/api-docs` link for complete details, request/response examples, and models.)

**Authentication:**
- `POST /users` - Register a new user (also used for web signup, but API returns JSON with token)
- `POST /auth/login` - Login to get a JWT token

**Murmurs:**
- `GET /api/murmurs` - Get all murmurs (public feed, paginated)
- `GET /api/murmurs/:id/detail` - Get details of a specific murmur
- `POST /api/me/murmurs` - Create a new murmur (authenticated user)
- `DELETE /api/me/murmurs/:id` - Delete own murmur (authenticated user)
- `GET /api/me/murmurs` - Get murmurs posted by the authenticated user

**Timeline:**
- `GET /api/timeline` - Get the personalized timeline for the authenticated user (murmurs from followed users and own murmurs, paginated)

**Follows:**
- `POST /api/follows` - Follow a user (`{ "followed_id": ID }`)
- `DELETE /api/follows/:id` - Unfollow a user (where `:id` is the ID of the user to unfollow)

**Likes:**
- `POST /api/likes` - Like a murmur (`{ "murmur_id": ID }`)
- `DELETE /api/likes/:id` - Unlike a murmur (where `:id` is the ID of the murmur to unlike)

**User Profiles:**
- `GET /api/profile/:username` - Get public profile information for a user.
- `GET /api/profile/:username/murmurs` - Get murmurs for a specific user.
- `GET /api/profile/:username/followers` - Get list of followers for a user.
- `GET /api/profile/:username/following` - Get list of users a user is following.

## Deviation from Requirements

- **JavaScript Bundling (Webpack):** The original requirement specified "Webpack". This project utilizes `importmap-rails` and `jsbundling-rails` (with `esbuild`) for JavaScript management. These are modern Rails conventions that fulfill the role of a JavaScript bundler, offering an alternative to directly using Webpack, rather than a deviation in capability.

## Impressions & Potential Future Work

- The application provides a solid foundation for a Twitter-like platform.
- The API is well-structured and documented with Swagger.
- The web interface is functional, leveraging Hotwire/Turbo and Stimulus for modern interactivity.
- **Future Enhancements could include:**
    - Real-time updates (e.g., ActionCable for new murmurs/notifications).
    - More advanced search functionality.
    - Direct messaging.
    - Hashtags and mentions.
    - Richer user profiles (e.g., profile pictures, header images).
    - Admin panel.

---
*This README was last updated on May 20, 2025.*
