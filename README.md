Dockerized Django App
=====================

Original template from [Hendrik Frentrup](https://github.com/hendrikfrentrup/docker-django).

Overview
--------

![Architecture](https://miro.medium.com/max/1260/1*b7WgN3pYpDzygae4LJ0e9g.png)

### Components
- web
  - Python (alpine)
  - Django
  - Gunicorn
- db
  - Postgres
- nginx
  - Nginx
- db-admin
  - PGAdmin

The root directory of this project contains the top-level Django directory `django`, the nginx configuration, as well as other project-level files.

### Web Addresses
If the PGAdmin server is unable to connect to the default port `[::]`, then set the follow in `docker-compose.override.yml`,
```
PGADMIN_LISTEN_ADDRESS='0.0.0.0'
```

### Environment Variables
This app uses environment variables to configure the various components.
This allows simple decoupling so that individual components can be run inside or outside of containers for development purposes.

Environment variables are read in the following order,
1. Shell environment
2. Local `.env` file
3. Hard-coded defaults

In production, shell environment variables should not be necessary, as a nominal `.env` file should exist - but will not be source-controlled along with this project for security purposes!

Template `.env` file,
```
DJANGO_WEB_HOST=site.com
DJANGO_DB_NAME=db
DJANGO_SECRET_KEY=secret

DJANGO_SU_NAME=admin
DJANGO_SU_EMAIL=admin@site.com
DJANGO_SU_PASSWORD=secret

POSTGRES_USER=postgres
POSTGRES_PASSWORD=secret

PGADMIN_DEFAULT_EMAIL=admin@site.com
PGADMIN_DEFAULT_PASSWORD=secret

SSL_CERTIFICATE=./nginx/certs/localhost.crt
SSL_CERTIFICATE_KEY=./nginx/certs/localhost.key
```

Optional development variables,
```
DJANGO_DEBUG=True
```

## Production

Obtain the production-ready `.env` file and place within project root.

Perform any database migrations and static file collection,
```
docker-compose -f docker-compose.migrate.yml build
docker-compose -f docker-compose.migrate.yml run --rm migrate
```

Build and start containers,
```
docker-compose pull
docker-compose up --build -d
```

Stop/start containers as necessary,
```
docker-compose stop
docker-compose start
```

Stop and remove containers,
```
docker-compose down
```

### PGAdmin

This image comes with an administrative interface to the Postgres database.

> Note: To keep configuration persistent, see note in docker-compose.override.yml

To log in, access via web interface (see network mappings, above).
Credentials should be availabile in `.env` file.
Click on “Add server”, set “Name” to anything we want, then click on the tab “Connection” and fill in 'db' as hostname, and the database credentials defined in the `.env` file for username and password.

## Development

### Enviornment variables

To run Django in debug mode, either change the local `.env` debug variable, or run `export DJANGO_DEBUG=True` in console window before starting containers.

### Running

> Note: If you would like the db-admin configuration to be persistent, see note in docker-compose.override.yml

Perform initial database migration to create superuser,
```
docker-compose -f docker-compose.migrate.yml run --rm migrate
```
> Note: May need to use `docker-compose -f docker-compose.migrate.yml build` prior to above cmd during development if `requirements.txt` changes.

The entire project can be brought up as in production,
```
docker-compose up -d
```

Or the Django web app can be run as an interactive session,
```
docker-compose up -d db
docker-compose run -p 8000:8000 web sh
```
and once in web container shell, start webserver with,
```
export DJANGO_DEBUG=True
python manage.py runserver 0:8000
```
and access at (http://localhost:8000).

### Adding an app to Django

Create new app,
```
python manage.py startapp <newappname>
```

Create database migrations before commit/deploy,
```
python manage.py makemigrations [<appname>]
```
