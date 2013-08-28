# Chef-Rails

Kitchen to setup an Ubuntu Server ready to roll with Nginx and Rails.

## Requirements

* Ubuntu 10.04+

## Usage

To cook with this kitchen you must follow four easy steps.

### 1. Prepare your local working copy

```bash
git clone git://github.com/acidlabs/chef-rails.git chef
cd chef
bundle install
librarian-chef install
```

### 2. Prepare the servers you want to configure

We need to copy chef-solo to any server we’re going to setup. For each server, execute

```bash
knife prepare [user]@[host] -p [port] --omnibus-version 10.14.2
```

where

* *user* is a user in the server with sudo and an authorized key.
* *host* is the ip or host of the server.
* *port* is the port in which ssh is listening on the server.

### 3. Define the specs for each server

If you take a look at the *nodes* folder, you’re going to see files called [host].json, corresponding to the hosts or ips of the servers we previously prepared, plus a file called *localhost.json.example* which is, as its name suggests, and example.

The specs for each server needs to be defined in those files, and the structure is exactly the same as in the example.

For the very same reason, we’re going to exaplain the example for you to ride on your own pony later on.

```json
{
  // This is the list of the recipes that are going to be cooked.
  "run_list": [
    "recipe[sudo]",
    "recipe[apt]",
    "recipe[build-essential]",
    "recipe[ohai]",
    "recipe[runit]",
    "recipe[git]",

    // If you want to use postgres, leave this as it is.
    // Otherwise, comment the three lines below.
    "recipe[postgresql::server]",
    "recipe[postgresql::server-dev]",
    "recipe[postgresql::libpq]",

    // If you want to use mysql, comment out the line below.
    // Otherwise, leave it as it is.
    // "recipe[mysql::server]",

    "recipe[nginx::default]",
    "recipe[nginx::apps]",
    "recipe[ruby]",

    // If you want to use monit
    "recipe[monit]"
    "recipe[monit::ssh]"
    "recipe[monit::nginx]"
    "recipe[monit::postgresql]"

    "recipe[chef-rails]"
  ],

  // You must define who’s going to be the user(s) you’re going to use for deploy.
  "authorization": {
    "sudo": {
      "groups":       ["vagrant"],
      "users":        ["vagrant"],
      "passwordless": true
    }
  },

  // You must define the username and password for postgres.
  // Comment if you're not going to use it.
  "postgresql": {
    "users": [
      {
        "username"  : "vagrant",
        "password"  : "asdf1234",
        "superuser" : true,
        "createdb"  : true,
        "login"     : true
      }
    ],

    // This is for postgres to trust in local connections. You should leave this as is
    // if you’re not sure what you’re doing.
    "pg_hba": [
      "local  all   all                 trust",
      "host   all   all   127.0.0.1/32  md5",
      "host   all   all   ::1/128       md5"
    ]
  },

  // If you're going to use mysql, comment out the following lines.
  // "mysql": {
  //   "server_root_password"  : "asdf1234",
  //   "server_repl_password"  : "asdf1234",
  //   "server_debian_password": "asdf1234",
  //   "server": {
  //     "packages": ["mysql-server", "libmysqld-dev"]
  //   }
  // },

  // You must specify the ubuntu distribution by it’s name to configure the proper version
  // of nginx, otherwise it’s going to fail.
  "nginx": {
    "user"          : "vagrant",
    "distribution"  : "oneiric",
    "components"    : ["main"],

    // Here you should define all the apps you want nginx to serve for you in the server.
    "apps": {

      // Example for an application served by Unicorn server
      "app1": {
        "listen"     : [80],
        "server_name": "app1.example.com",
        "public_path": "/home/vagrant/public_html/app1/current/public",
        "upstreams"  : [
          {
            "name"    : "app1",
            "servers" : ["unix:/home/vagrant/public_html/app1/shared/pids/app1.sock max_fails=3 fail_timeout=1s"]
          }
        ],
        "locations": [
          {
            "path": "/",
            "directives": [
              "proxy_set_header X-Forwarded-Proto $scheme;",
              "proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;",
              "proxy_set_header X-Real-IP $remote_addr;",
              "proxy_set_header Host $host;",
              "proxy_redirect off;",
              "proxy_http_version 1.1;",
              "proxy_set_header Connection '';",
              "proxy_pass http://app1;"
            ]
          },
          {
            "path": "~ ^/(assets)/",
            "directives": [
              "gzip_static on;",
              "expires max;",
              "add_header Cache-Control public;"
            ]
          }
        ]
      },

      // Example for an application served by Thin server
      "app2": {
        "listen"     : [80],
        "server_name": "app2.example.com",
        "public_path": "/home/vagrant/public_html/app2/current/public",
        "upstreams"  : [
          {
            "name"    : "app2",
            "servers" : [
              "localhost:3000 max_fails=3 fail_timeout=1s",
              "localhost:3001 max_fails=3 fail_timeout=1s",
              "localhost:3002 max_fails=3 fail_timeout=1s",
              "localhost:3003 max_fails=3 fail_timeout=1s"
            ]
          }
        ],
        "locations": [
          {
            "path": "/",
            "directives": [
              "proxy_set_header X-Forwarded-Proto $scheme;",
              "proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;",
              "proxy_set_header X-Real-IP $remote_addr;",
              "proxy_set_header Host $host;",
              "proxy_redirect off;",
              "proxy_http_version 1.1;",
              "proxy_set_header Connection '';",
              "proxy_pass http://app2;"
            ]
          },
          {
            "path": "~ ^/(assets)/",
            "directives": [
              "gzip_static on;",
              "expires max;",
              "add_header Cache-Control public;"
            ]
          }
        ]
      }
    }
  },

  // The ruby version you’re going to use. Valid values, by now, are 1.8, 1.9 and 1.9.1
  "languages": {
    "ruby": {
      "default_version": "1.9.1"
    }
  },

  // Finally, declare all the system packages required by the services and gems you’re using in your apps.
  // To give you an example: If you’re using nokogiri, the native extensions compilation will fail unless you have installed the development headers declared below.
  "chef-rails": {
    "packages": ["libxml2-dev", "libxslt1-dev", "libncurses5-dev", "libncurses5-dev", "redis-server", "sendmail"]
  }
}
```

### 4. Happy cooking

We’re now ready to cook. For each server you want to setup, execute

```bash
knife cook [user]@[host] -p [port]
```

following the same criteria we defined in step **2**.