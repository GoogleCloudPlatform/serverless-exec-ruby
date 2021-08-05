# Google Serverless Execution Tool

This repository contains the "google-serverless-exec" gem, a library for serverless execution. This may be used for safe running of ops and maintenance tasks, such as database migrations in a production serverless environment. It is not required for deploying a Ruby application to Google serverless compute, but it provides a number of convenience tools for integrating into Google serverless environments.

## Quickstart

To install, include the "google-serverless-exec" gem in your `Gemfile`:

```ruby
# Gemfile
gem "google-serverless-exec"
```

And then execute:

```ruby
$ bundle install
```

### Setting up serverless:exec execution

This library provides rake tasks for serverless execution, allowing
serverless applications to perform on-demand tasks in the serverless
environment. This may be used for safe running of ops and maintenance tasks,
such as database migrations, that access production cloud resources. 

You can add the Rake tasks to your application by adding the following to your Rakefile:

```ruby
require "google/serverless/exec/tasks"
```

You can run a production database migration in a Rails app using:

    bundle exec rake serverless:exec -- bundle exec rake db:migrate

The migration would be run in containers on Google Cloud infrastructure, which
is much easier and safer than running the task on a local workstation and
granting that workstation direct access to your production database.

## Development

The source code for this gem is available on Github at https://github.com/GoogleCloudPlatform/serverless-exec-ruby

The Ruby Serverless Exec is open source under the Apache 2.0 license.
Contributions are welcome. Please see the contributing guide at
https://github.com/GoogleCloudPlatform/serverless-exec-ruby/blob/main/CONTRIBUTING.md

Report issues at https://github.com/GoogleCloudPlatform/serverless-exec-ruby/issues
