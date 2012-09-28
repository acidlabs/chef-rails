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
knife prepare [user]@[host] -p [port]
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
/* This is the list of the recipes that are going to be cooked. */
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

// You must define who’s going to be the user(s) you’re going to use for deploy.
  "authorization": {
    "sudo": {
      "groups":       ["admin", "wheel", "sysadmin"],
      "users":        ["vagrant"],
      "passwordless": true
    }
  },

// You must define the username and password for postgres.
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

// If you want to create the databases manually, you can specify them here. otherwise, you can comment the databases array if you want.
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

// This is for postgres to trust in local connections. You should leave this as is if you’re not sure what you’re doing.
    "pg_hba": [
      "local  all   all                 trust",
      "host   all   all   127.0.0.1/32  md5",
      "host   all   all   ::1/128       md5"
    ]
  },

// You must specify the ubuntu distribution by it’s name to configure the proper version of nginx, otherwise it’s going to fail.
  "nginx": {
    "distribution": "oneiric",
    "components":   ["main"],
// Here you should define all the apps you want nginx to serve for you in the server.
    "apps": {
      "app1": {
        "listen"     : [80],
// Specify a server name
        "server_name": "app1.example.com",
// Specify a public path
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
// And never forget to set proxy pass to the actual ports you’re going to use.
// To give you an example: If you’re using unicorn as the app server, between ports 8000-8003, your proxy pass should be declared as below.
              "proxy_pass http://localhost:8000;"
            ]
          }
        ]
      },
// Same as above.
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

// The ruby version you’re going to use. Valid values, by now, are 1.8, 1.9 and 1.9.1
  "languages": {
      "ruby": {
          "default_version": "1.9.1"
      }
  },

// Finally, declare all the system packages required by the services and gems you’re using in your apps.
// To give you an example: If you’re using nokogiri, the native extensions compilation will fail unless you have installed the development headers declared below.
  "chef-rails": {
    "packages": ["libxml2-dev", "libxslt1-dev"]
  }
}
```

### 4. Happy cooking

We’re now ready to cook. For each server you want to setup, execute

```bash
knife cook [user]@[host] -p [port]
```

following the same criteria we defined in step **2**.