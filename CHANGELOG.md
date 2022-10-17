# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

- Added links to start a background task adding text to the record (or all records).
- The `Sorry Something Went Wrong` message popped up when the background job was started.
- Added the wrapper for a write context, but yet again `Sorry something went wrong` reared it's ugly head.

## Hotfix 2022-10-12

- correct path.
- Delete the postgres_write_handler and remove calling code. This appears to be the cause of the app blowing up.

## v0.0.5 2022-10-10

- Added code based on main app for connecting to the database.

## v0.0.4 2022-10-10

- enable the nginx server to get unicorn to display. Note that the `https://github.com/heroku/heroku-buildpack-nginx` build pack must be installed.

## v0.0.3 2022-10-06

Yes lots of releases today.

- Set up for Heroku
- Replace puma with unicorn to match production app
- Faffing on with Heroku settings. It compiles, but isn't loading properly

## v0.0.2 2022-10-06

- And a second attempt at doing the first 'release' version.

## v0.0.1 2022-10-06

- Initial build of application with a single (simple) model.
