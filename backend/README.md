# Backend API – mobile integration guide

FastAPI app for the movie recommendations product (see `src/main.py`). Use this as a quick reference when wiring the mobile client.

- **Base URL**: `http://localhost:8000` (adjust to your deployment)
- **Auth**: Bearer JWT in `Authorization: Bearer <access_token>`
- **Content type**: `application/json`
- **Health**: `GET /health` (checks Postgres, Redis, Celery broker)

## Auth (`/auth`)
- `POST /signup` → TokenPair  
  Body: `{ email, username, password }`
- `POST /login` → TokenPair  
  Body: `{ email, password }`
- `POST /refresh` → TokenPair  
  Body: `{ refresh_token }`
- `GET /me` → current user (`id, email, username, created_at`)

`TokenPair` shape: `{ access_token, refresh_token, token_type: "bearer" }`. Access tokens expire (see `ACCESS_TOKEN_EXPIRE_MINUTES` env). Refresh tokens are stored server-side in sessions.

## Profiles (`/profiles`)
- `GET /{user_id}` → ProfileOut  
  Returns `{ id, user_id, avatar_url?, bio?, location?, birthdate?, updated_at }`
- `PUT /{user_id}` → ProfileOut  
  Body: any subset of `{ avatar_url, bio, location, birthdate }`

## Movies (`/movies`)
Public CRUD (no auth required):
- `GET /` → list of MovieOut
- `POST /` → create Movie (admin/use with care). Body: `{ title, overview?, release_date?, rating?, popularity?, poster_url?, backdrop_url?, tmdb_id?, genres?, keywords? }`
- `GET /{movie_id}` → MovieOut
- `PUT /{movie_id}` → MovieOut (partial fields allowed)
- `DELETE /{movie_id}` → 204

User actions (auth required):
- `GET /recommendations?limit=20` → movies recommended for current user
- `POST /{movie_id}/favorites` → FavoriteOut; also triggers taste/recs refresh
- `DELETE /{movie_id}/favorites` → 204
- `POST /{movie_id}/dislikes` → DislikeOut
- `DELETE /{movie_id}/dislikes` → 204
- `PUT /{movie_id}/status` → StatusOut  
  Body: `{ status }`, where status ∈ `watching | want_to_watch | completed | dropped`
- `POST /{movie_id}/swipes` → Swipe  
  Body: `{ user_id, direction }`, direction ∈ `like | dislike` (must match current user)

`MovieOut`: `{ id, title, overview?, release_date?, rating?, popularity?, poster_url?, backdrop_url?, tmdb_id?, genres?, keywords? }`

## Friends (`/friends`)
All require auth.
- `GET /` → list accepted friends (FriendOut)
- `GET /requests` → incoming pending requests
- `POST /requests` → create friend request (FriendOut)  
  Body: `{ requester_id, addressee_id }` (requester must be current user)
- `POST /{friend_id}/accept` → FriendOut (only addressee may accept)
- `POST /{friend_id}/block` → FriendOut (either side may block)
- `GET /suggestions` → list of `{ user_id, username, email, similarity_score, top_genres }`

`FriendOut`: `{ id, requester_id, addressee_id, status (pending|accepted|blocked), created_at, updated_at }`

## Errors & notes
- Standard HTTP status codes; 401 for missing/invalid token, 403 for forbidden actions, 404 when resource not found, 400 on validation conflicts (e.g., duplicate friend request, existing email).
- Most write endpoints return created/updated row; deletes return 204 with empty body.
- Background tasks (Celery) recalc taste vectors and recommendations after favorites/dislikes/status/swipes.

