# Chef-Rails

Kitchen to setup an Ubuntu Server ready to roll with Nginx and Rails.

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
knife prepare [user]@[host] -p [port]
```

where

* *user* is a user in the server with sudo and an authorized key.
* *host* is the ip or host of the server.
* *port* is the port in which ssh is listening on the server.

### 3. Define the specs for each server

If you take a look at the *nodes* folder, you’re going to see files called [host].json, corresponding to the hosts or ips of the servers we previously prepared, plus a file called *localhost.json.example* which is, as its name suggests, and example.

The specs for each server needs to be defined in those files, and the structure is exactly the same as in the example.

For the very same reason, we’re going to exaplain the example for you to ride on your on wheels later on.

```json
{
  "run_list": [
    "recipe[sudo]",
    "recipe[apt]",
    "recipe[build-essential]",
    "recipe[ohai]",
    "recipe[runit]",
    "recipe[git]",
    "recipe[postgresql::server]",
    "recipe[postgresql::server-dev]",
    "recipe[postgresql::libpq]",
    "recipe[nginx::default]",
    "recipe[nginx::apps]",
    "recipe[ruby]",
    "recipe[chef-rails]"
  ],

  "authorization": {
    "sudo": {
      "groups":       ["admin", "wheel", "sysadmin"],
      "users":        ["vagrant"],
      "passwordless": true
    }
  },

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

    "databases": [
      {
        "name"      : "app1",
        "owner"     : "vagrant",
        "template"  : "template0",
        "encoding"  : "utf8",
        "locale"    : "en_US.UTF8"
      },
      {
        "name"      : "app2",
        "owner"     : "vagrant",
        "template"  : "template0",
        "encoding"  : "utf8",
        "locale"    : "en_US.UTF8"
      }
    ],

    "pg_hba": [
      "local  all   all                 trust",
      "host   all   all   127.0.0.1/32  md5",
      "host   all   all   ::1/128       md5"
    ]
  },

  "nginx": {
    "distribution": "oneiric",
    "components":   ["main"],
    "apps": {
      "app1": {
        "listen"     : [80],
        "server_name": "app1.example.com",
        "public_path": "/home/vagrant/public_html/app1/public",
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
              "proxy_pass http://localhost:8000;"
            ]
          }
        ]
      },
      "app2": {
        "listen"     : [80],
        "server_name": "app2.example.com",
        "public_path": "/home/vagrant/public_html/app2/public",
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
              "proxy_pass http://localhost:10000;"
            ]
          }
        ]
      }
    }
  },

  "languages": {
      "ruby": {
          "default_version": "1.9.1"
      }
  },

  "chef-rails": {
    "packages": ["libxml2-dev", "libxslt1-dev"]
  }
}
```