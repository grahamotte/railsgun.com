# RAILSGUN

Railsgun is a Rails-based launchpad application designed to be as *cheap as possible*.

It handles all the usual stuff you would want in a web app:

- Rails backend including many common gems
- React frontend
- Postgres DB
- Redis caching
- Sidekiq job running
- Let's encrypt certificates
- Network mounts
- and some other goodies...

## Setup

Railsgun was built for me, so it's pretty opinionated, but if you want to run it here's what you'll need:

1. Create a secrets.yml file: `~/.config/secrets/secrets.yml` and populate the keys:

```
id_rsa: (the deploy key)
linode_token: (manages the linode instance)
cloudflare_token: (manages dns)

+ any other keys you need for your rails app
```

2. Register a domain and point is nameservers to cloudflare

3. Close this repo then run `bin/prod init <app.name>`
