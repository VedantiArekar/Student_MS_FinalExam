# Student Management System

DevOps final project: a small web application to manage students (add, list, view, edit, delete, search), built with Ruby on Rails, PostgreSQL and vanilla JavaScript, and packaged with Docker.

---

## 1. Project overview

The application has two parts:

- **Backend:** a Ruby on Rails app with a PostgreSQL database. It offers a JSON REST API under `/api/students`.
- **Frontend:** one HTML page (a Rails ERB view) with plain CSS and vanilla JavaScript. The JavaScript calls the API with `fetch()` and updates the page without reloading it.

How one request flows (useful to explain in the exam):

```
Browser (app.js) --fetch--> Rails routes --> StudentsController --> Student model --> PostgreSQL
Browser (app.js) <--JSON--- StudentsController <--------------------------------------+
```

## 2. Technologies used

| Technology | Purpose |
|---|---|
| Ruby 3.3 | Programming language |
| Ruby on Rails 8.1.4 (or newer 8.1.x) | Web framework (MVC, Active Record) |
| PostgreSQL | Database |
| Puma | Application server |
| ERB, HTML, CSS | Page and styling |
| Vanilla JavaScript (`fetch`) | Frontend interaction, no libraries |
| Docker / Docker Compose | Container image and local multi-container setup |
| Minitest | Automated tests (included with Rails) |

## 3. Features

- Add, list, view, edit and delete students
- Search students by name (case-insensitive, partial match, live while typing)
- Dashboard with the total number of students
- Validation: all fields required, email format and uniqueness, semester is a whole number from 1 to 12
- Clear success and error messages; confirmation before deleting
- Page updates dynamically (no full reload)
- Responsive layout (works on phone and desktop)
- Health endpoint `/up` for Docker and Kubernetes
- Database settings only from environment variables (no passwords in the code)

## 4. Folder structure

```
Student_MS_FinalExam/
├── app/
│   ├── controllers/
│   │   ├── api/students_controller.rb   JSON API (CRUD + search)
│   │   ├── application_controller.rb    base controller for pages
│   │   └── home_controller.rb           shows the dashboard page
│   ├── models/
│   │   ├── application_record.rb        base model
│   │   └── student.rb                   validations + search
│   └── views/
│       ├── layouts/application.html.erb page frame (head, CSS, JS)
│       └── home/index.html.erb          dashboard, form, table
├── bin/
│   ├── rails, rake                      Rails command-line tools
│   └── docker-entrypoint                prepares the database, then starts the server
├── config/
│   ├── application.rb                   which Rails parts are loaded
│   ├── database.yml                     PostgreSQL settings from environment variables
│   ├── puma.rb                          Puma server settings
│   ├── routes.rb                        URLs -> controllers (+ /up health check)
│   └── environments/                    development / test / production settings
├── db/
│   ├── migrate/20261110090000_create_students.rb   creates the students table
│   └── seeds.rb                         optional sample data
├── public/
│   ├── css/style.css                    styling
│   └── js/app.js                        frontend logic (fetch calls)
├── test/                                model and API tests
├── .env.example                         template for the environment variables
├── Dockerfile                           builds the application image
├── docker-compose.yml                   runs app + PostgreSQL together
├── Gemfile                              Ruby dependencies
└── README.md
```

## 5. API endpoints

| HTTP method | Endpoint | Purpose | Success response |
|---|---|---|---|
| GET | `/api/students` | Retrieve all students | `200` `{ "total": 5, "students": [...] }` |
| GET | `/api/students?search=ali` | Search students by name | `200` same format, filtered |
| GET | `/api/students/:id` | Retrieve one student | `200` `{ "student": {...} }` |
| POST | `/api/students` | Create a student | `201` `{ "message": "...", "student": {...} }` |
| PATCH | `/api/students/:id` | Update a student | `200` `{ "message": "...", "student": {...} }` |
| DELETE | `/api/students/:id` | Delete a student | `200` `{ "message": "..." }` |
| GET | `/up` | Health check | `200` |

Error responses: `422` `{ "errors": ["Email has already been taken"] }` (invalid data), `404` `{ "error": "Student not found." }`, `400` (missing `student` parameter).

Request body for POST and PATCH:

```json
{ "student": { "full_name": "Anna Schmidt", "email": "anna@example.com", "course": "Computer Science", "semester": 2 } }
```

`total` always counts all students, even when a search is active.

## 6. Local installation (without Docker)

**Requirements:** Ruby 3.3, PostgreSQL 14 or newer (with its development headers, e.g. `libpq-dev` on Ubuntu), Bundler.

**Step 1: configure the environment**

```bash
cd Student_MS_FinalExam
cp .env.example .env
```

Open `.env` and set `DB_USER` and `DB_PASSWORD`. In development and test, the `dotenv-rails` gem loads this file automatically.

**Step 2: create the PostgreSQL user** (it needs permission to create databases)

```bash
# Linux
sudo -u postgres psql -c "CREATE USER student_user WITH PASSWORD 'change_this_password' CREATEDB;"
# macOS / Windows: connect with  psql -U postgres  and run the same CREATE USER command
```

No local PostgreSQL? Start one with Docker instead:

```bash
docker run -d --name student-pg -p 5432:5432 \
  -e POSTGRES_USER=student_user -e POSTGRES_PASSWORD=change_this_password \
  postgres:16
```

Use the same user and password you put in `.env`.

**Step 3: install gems, create the database, start the server**

```bash
bundle install
bin/rails db:create db:migrate
bin/rails db:seed          # optional: adds 5 sample students
bin/rails server
```

If `bin/rails` is not executable (Linux/macOS): `chmod +x bin/*`. On Windows use `ruby bin/rails ...`.

## 7. Database migration commands

| Command | What it does |
|---|---|
| `bin/rails db:create` | Creates the database |
| `bin/rails db:migrate` | Runs the migrations (creates the `students` table) |
| `bin/rails db:migrate:status` | Shows which migrations were run |
| `bin/rails db:rollback` | Undoes the last migration |
| `bin/rails db:seed` | Adds the sample students |
| `bin/rails db:prepare` | Creates the database if missing and migrates (used by Docker) |
| `bin/rails db:reset` | Drops, recreates and re-migrates (deletes all data) |

## 8. Running the tests

```bash
bin/rails db:create RAILS_ENV=test   # only the first time
bin/rails test
```

The tests use a separate database named `<DB_NAME>_test`, so your real data is never touched.

## 9. Docker

### Option A: Docker Compose (recommended)

```bash
cp .env.example .env                  # then edit the values
# create a secret key and paste it into .env as SECRET_KEY_BASE:
openssl rand -hex 64

docker compose up --build             # build and start (add -d to run in the background)
docker compose exec web bin/rails db:seed   # optional sample data
docker compose logs -f web            # show the application logs
docker compose down                   # stop (data is kept)
docker compose down -v                # stop and DELETE the database data
```

The database tables are created automatically when the web container starts.

### Option B: plain Docker commands

```bash
# 1. network and database
docker network create student-net
docker run -d --name student-db --network student-net \
  -e POSTGRES_DB=student_ms -e POSTGRES_USER=student_user -e POSTGRES_PASSWORD=change_this_password \
  -v student_pgdata:/var/lib/postgresql/data \
  postgres:16

# 2. build the application image
docker build -t student-ms:1.0 .

# 3. run the application (uses .env, DB_HOST is overridden for Docker)
docker run -d --name student-web --network student-net -p 3000:3000 \
  --env-file .env -e DB_HOST=student-db \
  student-ms:1.0

# useful
docker ps
docker logs -f student-web
docker stop student-web student-db
```

`DB_USER`, `DB_PASSWORD` and `DB_NAME` in `.env` must match the values used for the database container.

## 10. Accessing the application

| What | URL |
|---|---|
| Dashboard (web page) | http://localhost:3000 |
| All students (JSON) | http://localhost:3000/api/students |
| Health check | http://localhost:3000/up |

Test the API with curl:

```bash
# list
curl http://localhost:3000/api/students

# create
curl -X POST http://localhost:3000/api/students \
  -H "Content-Type: application/json" \
  -d '{"student":{"full_name":"Test User","email":"test@example.com","course":"Cybersecurity","semester":2}}'

# view one, update, delete (replace 1 with a real id)
curl http://localhost:3000/api/students/1
curl -X PATCH http://localhost:3000/api/students/1 \
  -H "Content-Type: application/json" -d '{"student":{"semester":3}}'
curl -X DELETE http://localhost:3000/api/students/1

# search by name
curl "http://localhost:3000/api/students?search=test"

# validation error (answers 422)
curl -i -X POST http://localhost:3000/api/students \
  -H "Content-Type: application/json" -d '{"student":{"full_name":""}}'

# health check
curl -i http://localhost:3000/up
```

## 11. Health checks (Docker and Kubernetes)

`/up` answers `200` when the application has started. The `Dockerfile` already contains a `HEALTHCHECK`. In Kubernetes use it for the probes:

```yaml
readinessProbe:
  httpGet: { path: /up, port: 3000 }
livenessProbe:
  httpGet: { path: /up, port: 3000 }
```

## 12. Configuration reference

| Variable | Used for | Default |
|---|---|---|
| `DB_HOST` | database server | `localhost` |
| `DB_PORT` | database port | `5432` |
| `DB_NAME` | database name (tests use `<DB_NAME>_test`) | `student_ms` |
| `DB_USER` | database user | none |
| `DB_PASSWORD` | database password | none |
| `SECRET_KEY_BASE` | Rails secret, **required in production** | none |
| `FORCE_SSL` | set to `true` behind an HTTPS proxy | off |
| `PORT` | port Puma listens on | `3000` |

## 13. Notes

- The API has no login, so anyone who can reach it can change the data. Adding authentication would be the next step for a real system.
- Rails 8.1.4 or a newer 8.1.x patch release is installed by `bundle install`. After the first install, commit `Gemfile.lock` so everyone uses exactly the same versions.
