# Submission Checklist

> Mirrors `Truck Signs API v2 Checkliste.pdf`. The checkboxes in that PDF are drawn
> glyphs, not form fields, so they cannot be ticked in the document itself - this file
> carries the state instead, in the same order as the PDF.
>
> Notes after a dash give the evidence for a tick where it is not obvious. Two items are
> still open and marked as such.

## 1. Repository

### Existing files

- [x] A `Dockerfile` is present and corrected according to the criteria below
- [x] A `docker-compose.yml` is present and corrected according to the criteria below
- [x] An `entrypoint.sh` is present and corrected according to the criteria below
- [x] A `README.md` is present and adapted according to the criteria below
- [x] No further files in the repository without being named and described in the
      `README.md` - every tracked top-level path has a row in *Repository Contents*

### Dockerfile

- [x] The base image uses a valid Python tag - `python:3.12-slim`, official, pinned to
      the minor version, not `latest`
- [x] The `pip install` command references `requirements.txt` correctly - with
      `--no-cache-dir`
- [x] `EXPOSE` gives a port number - `8000`, the port gunicorn binds inside the container
- [x] The `entrypoint.sh` script is marked executable in the Dockerfile - it is stored as
      mode `100644` in Git, so `COPY` alone would not carry the execute bit
- [x] The `ENTRYPOINT` references the script with a full path - `/app/entrypoint.sh`

### docker-compose.yml

- [x] The Postgres image uses a valid tag - `postgres:17-alpine`. Version 18 and later
      move `PGDATA`, which breaks a volume mounted at the conventional path; see the
      README
- [x] No `build` context any more, an image is referenced instead - the `build` key is
      kept in its mapping form together with an `image` key, as clarified by the mentor
      and by the course announcement of 2026-11-04
- [x] Sensitive values are not hardcoded - every value comes from `.env` through `${}`
- [x] Both services have a suitable restart policy - `on-failure`
- [x] A container port is published so the container is reachable from the internet -
      `8020:8000` on the backend service
- [x] The `backend` service has a port mapping
- [x] Both services are on the same Docker network - `tsa-network`
- [x] Volumes are configured so database data survives a restart and no permanent
      host-to-container connection exists - two named volumes, no bind mounts

### entrypoint.sh

- [x] The `while` loop waiting for the database contains `sleep`, so the script does not
      spin in a busy loop
- [x] The script runs `python manage.py migrate` before the application starts
- [x] The script creates a superuser automatically and skips the step when the user
      already exists

### README.md

- [x] The README contains a table of contents
- [x] The individual sections are linked in the table of contents - verified
      mechanically, no broken anchors
- [x] A section describing the repository, its essential contents and its purpose -
      placed directly under the title, as requested in the review
- [x] A *Quickstart* section naming the prerequisites and giving short instructions
- [x] A *how to build the image* subsection
- [x] A detailed variant of that section as *Usage*, covering configuration and how to
      modify relevant passages
- [x] It is documented how a container image is created
- [x] The `docker run` command is documented, with placeholders instead of environment
      values or other sensitive information

## 2. Documentation

- [x] Code and project are documented in the repository as a README file
- [x] The documentation language is English

## 3. Notes

### General

- [ ] A Loom video of at most 5 minutes showing the submission - **open**, to be recorded
      for this submission

### Security

- [x] No SSH keys in the workspace of the Git repository - verified across all tracked
      files
- [x] No passwords, tokens or usernames in the code - all of them come from environment
      variables
- [x] No IP addresses or other sensitive information in the repository - verified across
      all tracked files

### Code conventions

- [x] `UPPER_CASE_WITH_UNDERSCORE` for build args, environment and shell variables
- [x] Variable references always use the `${}` notation
- [x] Default values for build args and environment variables where they make sense -
      deliberately none for the required variables, so that a missing value fails loudly
      instead of falling back to the defaults in `settings.py`
- [x] Critical configuration is not stored in the repository but passed in through a
      `.env` file

### Testing

- [x] The Truck Signs API is reachable on port 8020 via the IP address of the cloud VM -
      verified in a browser, not with curl: the access log shows 200 for the pages and
      the static files and 302 for the admin login, with no worker timeouts
- [x] The `ENTRYPOINT` starts the WSGI application - the response carries
      `Server: gunicorn`; the development server would send `WSGIServer`
- [x] After restarting the setup the configured data is still present and is neither
      deleted nor overwritten - `docker compose down && docker compose up -d` reports
      `No migrations to apply.` and the superuser is still there
- [x] The containers restart as soon as an error terminates them - `restart: on-failure`
      on both services
- [x] There is no duplicate gunicorn start command - the `command` key was removed from
      `docker-compose.yml`; the entrypoint is the only place that starts gunicorn
