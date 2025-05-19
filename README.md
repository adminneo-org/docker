AdminNeo Docker image
=====================

**AdminNeo** is a full-featured database management tool written in PHP.

Supported database drivers:
- MySQL, MariaDB, PostgreSQL, SQLite, MS SQL, MongoDB, SimpleDB, Elasticsearch (beta), ClickHouse (alpha)

AdminNeo is based on the [Adminer](https://www.adminer.org/) project by Jakub Vrána.

<img src="https://raw.githubusercontent.com/adminneo-org/adminneo/refs/heads/main/docs/images/screenshot-select.webp" width="800" alt="Screenshot - Select data"/>

Tags
----

- `devel` - Latest but unstable image generated from git.

Usage
-----

```shell
docker run -d --name adminneo -p 8080:8080 adminneo:devel

docker run -d --name adminneo -p 8080:8080 \
  -e NEO_COLOR_VARIANT=green \
  -e NEO_PREFER_SELECTION=true \
  -e NEO_JSON_VALUES_DETECTION=true \
  -e NEO_JSON_VALUES_AUTO_FORMAT=true \
  -e NEO_VISIBLE_COLLATIONS='ascii_general_ci,utf8mb4*czech*ci' \
  -e NEO_HIDDEN_DATABASES=__system \
  -e NEO_HIDDEN_SCHEMAS=__system \
  -e NEO_DEFAULT_PASSWORD_HASH= \
  -e NEO_SSL_TRUST_SERVER_CERTIFICATE=true \
  adminneo:devel
```

Configuration
-------------

For detailed information see [Configuration documentation](https://github.com/adminneo-org/adminneo/blob/main/docs/configuration.md).

| Environment variable             | Default   | Description                                                                                                                                                         |
|----------------------------------|-----------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| NEO_THEME                        | `default` | Theme code. Available themes are: `default`.                                                                                                                        |
| NEO_COLOR_VARIANT                | `blue`    | Theme color variant. Available variants are: `blue`, `green`, `red`.                                                                                                |
| NEO_CSS_URLS                     | `null`    | Comma-separated list of custom CSS files.                                                                                                                           |
| NEO_JS_URLS                      | `null`    | Comma-separated list of custom JavaScript files.                                                                                                                    |
| NEO_NAVIGATION_MODE              | `simple`  | Main navigation mode that affects the left menu with the list of tables and top links: `simple`, `dual`, `reversed`.                                                |
| NEO_PREFER_SELECTION             | `false`   | Whether data selection is the primary action for all table links.                                                                                                   |
| NEO_JSON_VALUES_DETECTION        | `false`   | Whether to detect JSON objects and arrays in text columns.                                                                                                          |
| NEO_JSON_VALUES_AUTO_FORMAT      | `false`   | Whether to automatically format JSON values while editing.                                                                                                          |
| NEO_ENUM_AS_SELECT_THRESHOLD     | `5`       | Threshold for displaying `<select>` for `enum` fields instead of radio list in edit form.                                                                           |
| NEO_RECORDS_PER_PAGE             | `50`      | Number of selected records per one page.                                                                                                                            |
| NEO_VERSION_VERIFICATION         | `true`    | Whether verification of the new AdminNeo's version is enabled.                                                                                                      |
| NEO_HIDDEN_DATABASES             | `null`    | Comma-separated list of databases to hide from the UI. Value `__system` will be expanded to all system databases. Access to these databases will be not restricted. |
| NEO_HIDDEN_SCHEMAS               | `null`    | Comma-separated list of schemas to hide from the UI. Value `__system` will be expanded to all system schemas. Access to these schemas will be not restricted.       |
| NEO_VISIBLE_COLLATIONS           | `null`    | Comma-separated list of collations to keep in select boxes while editing databases or tables.                                                                       |
| NEO_DEFAULT_DRIVER               | `null`    | Default driver for login form.                                                                                                                                      |
| NEO_DEFAULT_PASSWORD_HASH        | `null`    | Hash of the default password for authentication to password-less databases. Set to an empty string to allow connection without password.                            |
| NEO_SSL_KEY                      | `null`    | MySQL: The path name to the SSL key file.                                                                                                                           |
| NEO_SSL_CERTIFICATE              | `null`    | MySQL: The path name to the certificate file.                                                                                                                       |
| NEO_SSL_CA_CERTIFICATE           | `null`    | MySQL: The path name to the certificate authority file.                                                                                                             |
| NEO_SSL_TRUST_SERVER_CERTIFICATE | `null`    | MySQL, MS SQL: Whether to trust server certificate. Values: `true`, `false`, `null`.                                                                                |
| NEO_SSL_MODE                     | `null`    | PostgreSQL: Value for [sslmode connection parameter](https://www.postgresql.org/docs/current/libpq-connect.html#LIBPQ-CONNECT-SSLMODE).                             |
| NEO_SSL_ENCRYPT                  | `null`    | MS SQL: Whether the communication is encrypted. Values: `true`, `false`, `null`.                                                                                    |

Custom CSS and JavaScript
-------------------------

It is possible to modify the appearance and functionality by creating a custom CSS or JavaScript file. AdminNeo will
automatically include files `adminneo.css`, `adminneo-light.css`, `adminneo-dark.css` and `adminneo.js` that are
placed in the AdminNeo's current working directory (typically next to the index.php).

- adminneo.css - Should be compatible with automatic switching to dark mode.
- adminneo-light.css - Will force AdminNeo to use only the light mode.
- adminneo-dark.css - Will force the dark mode.

This can be achieved by bind-mounting the files:
```shell
docker run -d --name adminneo -p 8080:8080 \
  -v "/some_path/adminneo.css:/var/www/html/adminneo.css" \
  -v "/some_path/adminneo.js:/var/www/html/adminneo.js" \
  adminneo:devel
```

More information
----------------

Source code and license information can be found on: https://github.com/adminneo-org/adminneo
