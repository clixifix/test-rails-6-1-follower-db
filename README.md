# test-rails-6-1-follower-db

A test repo for follower repo's.

An articles table has been added. You'd be suprised how little time I spent on the CSS.

## setup notes

Copy `.env.template` to `.env.development.local` and `.env.test.local`. Edit as required.
I am aware of the rails credentials idea. KISS.

```bash
rails _6.1.4.4_ new .  --database=postgresql
# Loads of output
```

You need to add the `https://github.com/heroku/heroku-buildpack-nginx` buildpack to enable the nginx reverse proxy. This is required for the Procfile.

You need to enable a background jobs worker.
