## Running the Application

1. Clone the repository
2. Install dependencies: `mix deps.get`
3. Create and migrate the database: `mix ecto.setup`
4. Start the Phoenix server: `mix phx.server`

The application will be available at `http://localhost:4000`.

### API Endpoints

- GET /api/cameras - List users with their active cameras
  - Query parameters:
    - camera_name: Filter by camera name
    - order: Sort by camera name (asc or desc)
- POST /api/notify-users - Notify users with Hikvision cameras
