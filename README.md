# HelpingCulture

**HelpingCulture** is an application that aims to make ticket and volunteer
management for community events easier.

The idea was originally conceived and inspired by Tracy Page.

## Getting Started

If you want to contribute to the HelpingCulture codebase, there's a few things
you need to do in order to get started.

  * Run a Mac or Linux operating system

  * Clone this repository: `git clone git@github.com:sds/helpingculture.git`

  * Install [Dock](https://github.com/brigade/dock):
    ```bash
    brew cask install docker
    brew tap brigade/dock
    brew install dock
    ```

    If you're on macOS, remember to follow the
    [additional instructions for setting up Dock](https://github.com/brigade/dock#docker-for-mac).

  * Open a shell to the Dockerized environment using Dock:
    ```bash
    cd path/to/repo
    dock
    ```

  * Create a database user for the HelpingCulture Rails application to use when
    connecting to Postgres. Connect as the `postgres` (or whatever user has
    admin privileges) user using the `psql` utility, and then run:
    `CREATE ROLE app WITH CREATEDB LOGIN PASSWORD 'dev_password';`
    The `app` and `dev_password` are up to you.

  * Copy the `config/database.yml.example` file to `config/database.yml`, and
    edit the `username` and `password` fields to match the user/password you
    chose in the previous step (you can use the defaults if you want).

  * Copy the `config/stripe.yml.example` file to `config/stripe.yml`. If you
    have your own Stripe account that you want to test with, use the secret
    key and public key from that account instead (but the defaults will work
    out of the box if you don't want to use your own Stripe account).

  * Create the databases using the information you defined in
    `config/database.yml` by running `rake db:create`

  * Fill the database with tables by running the database migrations:
    `rake db:migrate db:test:prepare` (the `db:test:prepare` is necessary
    only if you want to run the tests)

You should now be all set. Try spinning up a local development server by
running:

    bundle exec rails server

This should run an all-in-one server that you can access from your browser
at `http://localhost:3000`. It will also automatically load any changes
you make to code in the repo's `app` directory. Changes anywhere else will
require you to restart the server.

If you want to work within a Ruby console, `rails console` is incredibly
useful for playing around in the Rails environment.

## Contributing

### Write helpful commit messages

When making changes to the code, ensure your commit messages are descriptive.
A good summary of git commit messages can be found
[here](http://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html),
but you can look at the repository history for some examples using `git log`.

### Write tests

Automated tests are your friend. See the `spec` directory for examples.
You can run the automated tests by running `bundle exec rspec spec`
(where `spec` is the directory of specs, or individual list of specs, that you
want to run) in the repository.

## Deploying

If your SSH public key has been added to the production server's list of
authorized keys, you can deploy the latest version of the code to the
production site using `cap deploy`. Before you do this, remember to push
your local changes to the `origin` repository with `git push origin master`,
as the deploy process can only deploy code from that canonical source.

If you don't have permission to deploy, you can submit a pull request to
the repository and someone will review your code and merge it if it's good
to go.
See [Using Pull Requests](https://help.github.com/articles/using-pull-requests)
for more information on this process if you are not familiar.

## Help

If you need any more help, don't be afraid to ask!
