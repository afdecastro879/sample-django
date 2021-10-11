# Getting Started

This application is the standard [Django Polls Tutorial](https://docs.djangoproject.com/en/3.1/intro/tutorial01/) with an added page at `/`.
This app uses a Postgres database by default.

## Environment Variables

Many of the Django settings necessary to have an app run on App Platform have been exposed as environment variables. Below
is a list and what they do

- _DEBUG_ - Set Django to debug mode. Defaults to `False`.
- _DJANGO_ALLOWED_HOSTS_ - The hostnames django is allowed to receive requests from. This defaults to `127.0.0.1,localhost`. Can be a comma deliminated list. For more information about `allowed_hosts` view the [django documentation](https://docs.djangoproject.com/en/3.1/ref/settings/#allowed-hosts).
- _DEVELOPMENT_MODE_ - This determines whether to use a Postgres db or local sqlite. Defaults to `False` therefore using the Postgres db
- _DATABASE_URL_ - The connection url including port, username, and password to connect to a postgres db. This is provided by App Platform. Required if _DEVELOPMENT_MODE_ is `False`. For example: postgres://postgres:password@localhost:5432/postgres

## Setup

You can use a virtualenv to sandbox to install the rquirements:

```
  python3 -m venv env
  pip install -r requirements.txt
```

_Mac OS: Please note_
You will need to install openssl and export the flags:

```
  brew install openssl
  export LDFLAGS="-L/usr/local/opt/openssl/lib"
  export CPPFLAGS="-I/usr/local/opt/openssl/include"
```

With Postgres running migrate the database

```
python manage.py migrate
```

And setup superuser

```
python manage.py createsuperuser
```

And collect static files

```
python manage.py collectstatic
```

And start the server on http://localhost:8000

```
python manage.py runserver
```
