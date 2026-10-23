# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repository is

Packaging for the `adminneoorg/adminneo` Docker image (Docker Hub). It does **not** contain AdminNeo itself: the
Dockerfile clones https://github.com/adminneo-org/adminneo at build time and compiles it into a single `index.php`.
The only code here is the Dockerfile, three shell scripts in `bin/`, and a few files in `src/` copied into the image.
There are no tests and no linters.

The README.md doubles as the Docker Hub description. When a config variable is added or changed, update both
`src/adminneo-config.php` and the table in README.md.

## Build and run

Images are built multi-platform (linux/amd64 + linux/arm64) with `docker buildx`, so a full build is slow.

```shell
sh bin/build.sh -t devel        # build from AdminNeo's main branch (cache-busted with a timestamp)
sh bin/build.sh -t latest       # build the highest stable v*.*.* tag of AdminNeo
sh bin/build.sh -t 5.0.0        # build AdminNeo tag v5.0.0
sh bin/run-devel.sh             # build devel, then (re)start container `adminneo-devel` on port 8080
sh bin/build-release.sh         # build both the versioned and the `latest` image for the newest stable tag
```

`build.sh` maps the image tag to the AdminNeo git ref (`GIT_TAG` build arg): `devel` → `main`, `latest` → newest
`v*.*.*` tag without a pre-release suffix (resolved via `git ls-remote`), anything else → `v<tag>`. The `latest`
resolution uses GNU `head --lines=1`. Builds always run with `--pull` so a stale locally cached base image is never
used.

## How the image is put together

- **Base image** `trafex/php-nginx`: nginx + php-fpm on Alpine, listens on 8080, runs as `nobody`, webroot
  `/var/www/html`. The Dockerfile switches to root only to install packages, then back to `nobody` before cloning
  and compiling AdminNeo.
- **PHP extensions**: Alpine `php85-*` packages for pgsql, sqlite3, mongodb, etc. The PHP version is pinned by the
  package prefix (`php85`, `pecl85`), so a PHP bump means changing every such name. The extensions depend on
  `php85-common` without a version, so `apk upgrade` must run before `apk add`. Otherwise a base image older than
  the Alpine repository gets new extensions on an old PHP binary and they fail with "symbol not found". A later
  `RUN` step fails the build when `php -m` prints a warning or a required extension is missing; keep its extension
  list in sync with the installed packages.
- **MS SQL**: the Microsoft ODBC driver (`msodbcsql18`) is downloaded as an Alpine package, GPG-verified and
  installed, then `sqlsrv` is built via PECL. Build tools are removed in the same `RUN` layer. The package
  architecture is derived from `TARGETPLATFORM` by stripping the leading `linux/` (`${TARGETPLATFORM:6}`), which
  is why buildx with explicit platforms is required.
- **Compilation**: `php adminneo/bin/compile.php <drivers> -o index.php` with the full driver list
  (mysql,pgsql,mssql,sqlite,mongo,elastic,clickhouse,simpledb). No theme argument is passed, so all themes are
  compiled in and `NEO_THEME` selects one at runtime. The `CACHE_BUST` arg precedes this step so `devel` builds
  always re-clone.
- **Runtime config**: `src/php.ini` is copied to `conf.d/custom.ini` (loads `sqlsrv.so`, 1G upload limits,
  `max_input_vars = 5000`), and nginx gets `client_max_body_size 1G` via `sed`.

## Configuration glue (`src/`)

AdminNeo loads `adminneo-config.php` and `adminneo-plugins.php` from the directory next to `index.php`; both are
copied to `/var/www/html` and users override them by bind-mounting.

- `adminneo-config.php` maps `NEO_*` environment variables to AdminNeo config option names and returns the config
  array. Unset variables are skipped. Values are coerced: the strings `null`/`true`/`false` become those PHP values,
  numeric strings become `int`, everything else stays a string. Comma-separated lists are passed through as strings
  for AdminNeo to split. To add an option, add one entry to the `$variables` map and a README row.
- `adminneo-plugins.php` returns the list of enabled plugin instances. All official plugins are compiled into the
  image; only `JsonPreviewPlugin` is enabled by default.
- `info.php` is a `phpinfo()` page for debugging. Its `COPY` line in the Dockerfile is commented out; keep it that
  way in published images.
