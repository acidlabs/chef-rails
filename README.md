# Chef-Rails

Kitchen to setup an Ubuntu Server ready to roll for Ruby on Rails stack:

* Nginx
* PostgreSQL
* Redis
* Memcached
* Ruby with RVM
* Phusion Passenger Standalone

## Requirements

* Ubuntu 12.04+

## Usage

To cook with this kitchen you must follow four easy steps.

### 0. Create server deploy user (Optional)

We create our deploy user in deploy server adding our SSH keys:
```bash
sudo adduser deploy --gecos "" --disabled-password
# Add your SSH keys to deploy authorized_keys
sudo cp -R .ssh/ /home/deploy/
sudo chown -R deploy:deploy /home/deploy/
```

### 1. Prepare your local working copy

```bash
git clone git://github.com/acidlabs/chef-rails.git chef
cd chef
bundle install
bundle exec librarian-chef install
```

### 2. Prepare the servers you want to configure

We need to copy chef-solo to any server we’re going to setup. For each server, execute

```bash
bundle exec knife solo prepare [user]@[host] -p [port]
```

where

* *user* is a user in the server with sudo and an authorized key.
* *host* is the ip or host of the server.
* *port* is the port in which ssh is listening on the server. Defaul port: 22.

### 3. Define the specs for each server

If you take a look at the *nodes* folder, you’re going to see files called [host].json, corresponding to the hosts or ips of the servers we previously prepared, plus a file called *localhost.json.example* which is, as its name suggests, and example.

The specs for each server needs to be defined in those files, and the structure is exactly the same as in the example.

For the very same reason, we’re going to exaplain the example for you to ride on your own pony later on.

```json
{
  // This is the list of the recipes that are going to be cooked.
  "run_list": [
    "recipe[apt]",
    "recipe[sudo]",
    "recipe[hostnames]",
    "recipe[ssh-hardening]",
    "recipe[dpkg_packages]",
    "recipe[timezone-ii]",
    "recipe[postgresql::server]",
    "recipe[postgresql::contrib]",
    "recipe[postgresql::libpq]",
    "recipe[nginx::server]",
    "recipe[rvm::user]",
    "recipe[passenger]",
    "recipe[redis::server]",
    "recipe[memcached]",
    "recipe[fail2ban]"
  ],

  "automatic": {
    "ipaddress": "<host_ip>"
  },

  // You must define who’s going to be the user(s) you’re going to use for deploy.
  "authorization": {
    "sudo": {
      "groups"      : ["sudo","admin"],
      "users"       : ["deploy","vagrant"],
      "passwordless": true
    }
  },

  // Set hostname
  "set_fqdn": "<myhostname>",

  // List all the system packages required by the services and gems you’re using in your apps.
  // To give you an example: If you’re using paperclip, the native extensions compilation will fail unless you have installed imagemagick declared below.
  "dpkg_packages": {
    "pkgs": {
      "tzdata"     : { "action": "upgrade" },
      "nodejs-dev" : { "action": "install" },
      "imagemagick": { "action": "install" },
      "htop"       : { "action": "install" }
    }
  },

  // Select Timezone you want to configure
  "tz": "America/Santiago",

  // Postgresql configuration. You can create several users.
  "postgresql": {
    "shared_buffers": "256MB", // 1/4 of total memory is recommended
    "shared_preload_libraries": "pg_stat_statements",
    "users": [
      {
        "username": "deploy",
        "password": "123456",
        "superuser": true,
        "login": true
      }
    ]
  },

  // Nginx default values configuration.
  // Also you can specify your default site configuration.
  "nginx": {
    "user"                : "deploy",
    "client_max_body_size": "2m",
    "worker_processes"    : "auto",
    "worker_connections"  : 768,
    "repository"          : "ppa",
    "site"                : {
      "host"           : "<myhostname>",
      "upstream_ports" : ["3000"],
      "ip"             : "0.0.0.0",
      "listen"         : "80"
    }
  },

  // The default ruby version and gemset you’re going to use and rvm user.
  "rvm" : {
    "user_installs": [
      {
        "user"         : "deploy",
        "default_ruby" : "<ruby-version>@<gemset>"
      }
    ]
  },

  // Fail2ban configuration to protect our server against SSH attack attempts
  "fail2ban": {
    "bantime" : 600,
    "maxretry": 3,
    "backend" : "auto"
  }
}
```

### 4. Happy cooking

We’re now ready to cook. For each server you want to setup, execute

```bash
bundle exec knife solo cook [user]@[host] -p [port]
```

following the same criteria we defined in step **2**.

Remember to clean your kitchen after cook

```bash
bundle exec knife solo clean [user]@[host] -p [port]
```

### 5. Testing against a vagrant machine with knife-solo

Initialize the vagrant machine
```bash
vagrant up
```
Then locate the ssh key used by the vagrant machine 
```bash
vagrant ssh-config | grep IdentityFile | sed 's/.*IdentityFile//'
```
Finally connect and prepare && cook knife solo
```bash
knife solo prepare vagrant@127.0.0.1 -p 2222 -i /Your/vagrant/private_key
knife solo cook vagrant@127.0.0.1 nodes/vagrant.json.example -p 2222 -i /Your/vagrant/private_key 
```
