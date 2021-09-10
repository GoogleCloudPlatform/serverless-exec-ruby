# frozen_string_literal: true

# Copyright 2021 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


require "shellwords"

require "google/serverless/exec/gcloud"
require "google/serverless/exec"

module Google
  module Serverless
    class Exec
      ##
      # # Rake Task for serverless exec
      #
      # This module implements the `serverless:exec` rake task. To make it
      # available, add the line
      #
      #     require "google/serverless/exec/tasks"
      #
      # to your Rakefile. If your app uses Ruby on Rails, then the gem provides
      # a railtie that adds this task automatically, so you don't have to do
      # anything beyond adding the gem to your Gemfile.
      #
      # ## Usage
      #
      # The `serverless:exec` a given command in the context of a serverless
      # application. See {Google::Serverless::Exec} for more information on
      # this capability.
      #
      # The command to be run may either be provided as a rake argument, or as
      # command line arguments, delimited by two dashes `--`. (The dashes are
      # needed to separate your command from rake arguments and flags.)
      # For example, to run a production database migration, you can run either
      # of the following equivalent commands:
      #
      #     bundle exec rake "serverless:exec[bundle exec bin/rails db:migrate]"
      #     bundle exec rake serverless:exec -- bundle exec bin/rails db:migrate
      #
      # To display usage instructions, provide two dashes but no command:
      #
      #     bundle exec rake serverless:exec --
      #
      # ## Parameters
      #
      # You may customize the behavior of the serverless execution through a few
      # enviroment variable parameters. These are set via the normal mechanism
      # at the end of a rake command line. For example, to set EXEC_APP_CONFIG:
      #
      #     bundle exec rake serverless:exec EXEC_APP_CONFIG=myservice.yaml -- bundle exec bin/rails db:migrate
      #
      # Be sure to set these parameters before the double dash. Any arguments
      # following the double dash are interpreted as part of the command itself.
      #
      # The following environment variable parameters are supported:
      #
      # ### EXEC_PROJECT
      #
      # The ID of your Google Cloud project. If not specified, uses the current
      # project from gcloud.
      #
      # ### EXEC_PRODUCT
      #
      # The product used to deploy the app. Valid values are `app_engine` or
      # `cloud_run`. If omitted, the task will try to guess based on whether
      # an App Engine config file (e.g. `app.yaml`) is present.
      #
      # ### EXEC_REGION
      #
      # The Google Cloud region to which the app is deployed. Required for
      # Cloud Run apps.
      #
      # ### EXEC_STRATEGY
      #
      # The execution strategy to use. Valid values are `deployment` (which is
      # the default for App Engine Standard apps) and `cloud_build` (which is
      # the default for App Engine Flexible and Cloud Run apps).
      #
      # Normally you should leave the strategy set to the default. The main
      # reason to change it is if your app runs on the Flexible Environment and
      # talks to a database over a VPC (using a private IP address). The
      # `cloud_build` strategy used by default for Flexible apps cannot connect
      # to a VPC, so you should use `deployment` in this case. (But note that,
      # otherwise, the `deployment` strategy is significantly slower for apps
      # on the App Engine Flexible Environment.)
      #
      # ### EXEC_TIMEOUT
      #
      # Amount of time to wait before serverless:exec terminates the command.
      # Expressed as a string formatted like: `2h15m10s`. Default is `10m`.
      #
      # ### EXEC_SERVICE_NAME
      #
      # Name of the service to be used. If your app uses Cloud Run, this is
      # required. If your app uses App Engine, normally the service name is
      # obtained from the config file, but you can override it using this
      # parameter.
      #
      # ### EXEC_APP_CONFIG
      #
      # Path to the App Engine config file, used when your app has multiple
      # services, or the config file is otherwise not called `./app.yaml`. The
      # config file is used to determine the name of the App Engine service.
      # Unused for Cloud Run apps.
      #
      # ### EXEC_APP_VERSION
      #
      # The version of the App Engine service, used to identify which
      # application image to use to run your command. If not specified, uses
      # the most recently created version, regardless of whether that version
      # is actually serving traffic. Applies only to the `cloud_build` strategy
      # for App Engine apps; ignored for the `deployment` strategy or if your
      # app uses Cloud Run.
      #
      # ### EXEC_BUILD_LOGS_DIR
      #
      # GCS bucket name of the cloud build log when GAE_STRATEGY is
      # `cloud_build`. (ex. `gs://BUCKET-NAME/FOLDER-NAME`)
      #
      # ### EXEC_WRAPPER_IMAGE
      #
      # The fully-qualified name of the wrapper image to use. (This is a Docker
      # image that emulates the App Engine environment in Google Cloud Build
      # for the `cloud_build` strategy, and applies only to that strategy.)
      # Normally, you should not override this unless you are testing a new
      # wrapper.
      #
      module Tasks
        ## @private
        PROJECT_ENV = "EXEC_PROJECT"
        ## @private
        STRATEGY_ENV = "EXEC_STRATEGY"
        ## @private
        CONFIG_ENV = "EXEC_APP_CONFIG"
        ## @private
        SERVICE_ENV = "EXEC_SERVICE_NAME"
        ## @private
        VERSION_ENV = "EXEC_APP_VERSION"
        ## @private
        TIMEOUT_ENV = "EXEC_TIMEOUT"
        ## @private
        WRAPPER_IMAGE_ENV = "EXEC_WRAPPER_IMAGE"
        ## @private
        LOGS_DIR_ENV = "EXEC_BUILD_LOGS_DIR"
        ## @private
        PRODUCT_ENV = "EXEC_PRODUCT"
        ## @private
        REGION_ENV = "EXEC_REGION"

        @defined = false

        class << self
          ##
          # @private
          # Define rake tasks.
          #
          def define
            if @defined
              puts "Serverless rake tasks already defined."
              return
            end
            @defined = true

            setup_exec_task
          end

          private

          def setup_exec_task
            ::Rake.application.last_description =
              "Execute the given command in a Google serverless application."
            ::Rake::Task.define_task "serverless:exec", [:cmd] do |_t, args|
              command = extract_command args[:cmd], ::ARGV
              verify_gcloud_and_report_errors
              selected_product = extract_product ::ENV[PRODUCT_ENV]
              app_exec = Exec.new command,
                                  project:       ::ENV[PROJECT_ENV],
                                  service:       ::ENV[SERVICE_ENV],
                                  config_path:   ::ENV[CONFIG_ENV],
                                  version:       ::ENV[VERSION_ENV],
                                  timeout:       ::ENV[TIMEOUT_ENV],
                                  wrapper_image: ::ENV[WRAPPER_IMAGE_ENV],
                                  strategy:      ::ENV[STRATEGY_ENV],
                                  gcs_log_dir:   ::ENV[LOGS_DIR_ENV],
                                  region:        ::ENV[REGION_ENV],
                                  product:       selected_product
              start_and_report_errors app_exec
              exit
            end
          end

          def extract_command cmd, argv
            if cmd
              ::Shellwords.split cmd
            else
              i = (argv.index { |a| a.to_s == "--" } || -1) + 1
              if i.zero?
                report_error <<~MESSAGE
                  No command provided for serverless:exec.
                  Did you remember to delimit it with two dashes? e.g.
                  bundle exec rake serverless:exec -- bundle exec ruby myscript.rb
                  For detailed usage instructions, provide two dashes but no command:
                  bundle exec rake serverless:exec --
                MESSAGE
              end
              command = ::ARGV[i..-1]
              if command.empty?
                show_usage
                exit
              end
              command
            end
          end

          def extract_product product
            return unless product

            product = product.dup
            product.downcase!
            case product
            when "app_engine"
              APP_ENGINE
            when "cloud_run"
              CLOUD_RUN
            end
          end

          def show_usage
            puts <<~USAGE
              rake serverless:exec
              This Rake task executes a given command in the context of a serverless
              application. For more information,
              on this capability, see the Google::Serverless::Exec documentation at
              http://www.rubydoc.info/gems/google-serverless-exec/Google/Serverless/Exec
              The command to be run may either be provided as a rake argument, or as
              command line arguments delimited by two dashes "--". (The dashes are
              needed to separate your command from rake arguments and flags.)
              For example, to run a production database migration, you can run either
              of the following equivalent commands:
                  bundle exec rake "serverless:exec[bundle exec bin/rails db:migrate]"
                  bundle exec rake serverless:exec -- bundle exec bin/rails db:migrate
              To display these usage instructions, provide two dashes but no command:
                  bundle exec rake serverless:exec --
              You may customize the behavior of the serverless execution through a few
              enviroment variable parameters. These are set via the normal mechanism at
              the end of a rake command line but before the double dash. For example, to
              set EXEC_APP_CONFIG:
                  bundle exec rake serverless:exec EXEC_APP_CONFIG=myservice.yaml -- \\
                    bundle exec bin/rails db:migrate
              Be sure to set these parameters before the double dash. Any arguments
              following the double dash are interpreted as part of the command itself.
              The following environment variable parameters are supported:
              EXEC_PROJECT
                The ID of your Google Cloud project. If not specified, uses the current
                project from gcloud.
              EXEC_PRODUCT
                The product used to deploy the app. Valid values are "app_engine" or
                "cloud_run". If omitted, the task will try to guess based on whether
                an App Engine config file (e.g. app.yaml) is present.
              EXEC_REGION
                The Google Cloud region to which the app is deployed. Required for
                Cloud Run apps.
              EXEC_STRATEGY
                The execution strategy to use. Valid values are "deployment" (which is the
                default for App Engine Standard apps) and "cloud_build" (which is the
                default for App Engine Flexible and Cloud Run apps).
                Normally you should leave the strategy set to the default. The main reason
                to change it is if your app runs on the Flexible Environment and talks to
                a database over a VPC (using a private IP address). The "cloud_build"
                strategy used by default for Flexible apps cannot connect to a VPC, so you
                should use "deployment" in this case. (But note that, otherwise, the
                "deployment" strategy is significantly slower for apps on the Flexible
                environment.)
              EXEC_TIMEOUT
                Amount of time to wait before serverless:exec terminates the command.
                Expressed as a string formatted like: "2h15m10s". Default is "10m".
              EXEC_SERVICE_NAME
                Name of the service to be used. If your app uses Cloud Run, this is
                required. If your app uses App Engine, normally the service name is
                obtained from the config file, but you can override it using this
                parameter.
              EXEC_APP_CONFIG
                Path to the App Engine config file, used when your app has multiple
                services, or the config file is otherwise not called "./app.yaml". The
                config file is used to determine the name of the App Engine service.
                Unused for Cloud Run apps.
              EXEC_APP_VERSION
                The version of the App Engine service, used to identify which
                application image to use to run your command. If not specified, uses
                the most recently created version, regardless of whether that version
                is actually serving traffic. Applies only to the "cloud_build" strategy
                for App Engine apps; ignored for the "deployment" strategy or if your
                app uses Cloud Run.
              EXEC_BUILD_LOGS_DIR
                GCS bucket name of the cloud build log when GAE_STRATEGY is "cloud_build".
                (ex. "gs://BUCKET-NAME/FOLDER-NAME")
              EXEC_WRAPPER_IMAGE
                The fully-qualified name of the wrapper image to use. (This is a Docker
                image that emulates the App Engine environment in Google Cloud Build for
                the "cloud_build" strategy, and applies only to that strategy.) Normally,
                you should not override this unless you are testing a new wrapper.
            USAGE
          end

          def verify_gcloud_and_report_errors
            Exec::Gcloud.verify!
          rescue Exec::Gcloud::BinaryNotFound
            report_error <<~MESSAGE
              Could not find the `gcloud` binary in your system path.
              This tool requires the Google Cloud SDK. To download and install it,
              visit https://cloud.google.com/sdk/downloads
            MESSAGE
          rescue Exec::Gcloud::GcloudNotAuthenticated
            report_error <<~MESSAGE
              The gcloud authorization has not been completed. If you have not yet
              initialized the Google Cloud SDK, we recommend running the `gcloud init`
              command as described at https://cloud.google.com/sdk/docs/initializing
              Alternately, you may log in directly by running `gcloud auth login`.
            MESSAGE
          rescue Exec::Gcloud::ProjectNotSet
            report_error <<~MESSAGE
              The gcloud project configuration has not been set. If you have not yet
              initialized the Google Cloud SDK, we recommend running the `gcloud init`
              command as described at https://cloud.google.com/sdk/docs/initializing
              Alternately, you may set the default project configuration directly by
              running `gcloud config set project <project-name>`.
            MESSAGE
          end

          def start_and_report_errors app_exec
            app_exec.start
          rescue Exec::ConfigFileNotFound => e
            report_error <<~MESSAGE
              Could not determine which service should run this command because the App
              Engine config file "#{e.config_path}" was not found.
              Specify the config file using the EXEC_APP_CONFIG argument. e.g.
                bundle exec rake serverless:exec EXEC_APP_CONFIG=myapp.yaml -- myscript.sh
              Alternately, specify a service name directly with EXEC_SERVICE_NAME. e.g.
                bundle exec rake serverless:exec EXEC_SERVICE_NAME=myservice -- myscript.sh
            MESSAGE
          rescue Exec::BadConfigFileFormat => e
            report_error <<~MESSAGE
              Could not determine which service should run this command because the App
              Engine config file "#{e.config_path}" was malformed.
              It must be a valid YAML file.
              Specify the config file using the EXEC_APP_CONFIG argument. e.g.
                bundle exec rake serverless:exec EXEC_APP_CONFIG=myapp.yaml -- myscript.sh
              Alternately, specify a service name directly with EXEC_SERVICE_NAME. e.g.
                bundle exec rake serverless:exec EXEC_SERVICE_NAME=myservice -- myscript.sh
            MESSAGE
          rescue Exec::NoSuchVersion => e
            if e.version
              report_error <<~MESSAGE
                Could not find version "#{e.version}" of service "#{e.service}".
                Please double-check the version exists. To use the most recent version by
                default, omit the EXEC_APP_VERSION argument.
              MESSAGE
            else
              report_error <<~MESSAGE
                Could not find any versions of service "#{e.service}".
                Please double-check that you have deployed this service. If you want to run
                a command against a different service, you may provide a EXEC_APP_CONFIG
                argument pointing to your App Engine config file, or a EXEC_SERVICE_NAME
                argument to specify a service directly.
              MESSAGE
            end
          rescue Exec::NoDefaultProject
            report_error <<~MESSAGE
              Could not get the default project from gcloud.
              Please either set the current project using
                gcloud config set project my-project-id
              or specify the project by setting the EXEC_PROJECT argument. e.g.
                bundle exec rake serverless:exec EXEC_PROJECT=my-project-id -- myscript.sh
            MESSAGE
          rescue Exec::UsageError => e
            report_error e.message
          end

          def report_error str
            warn str
            exit 1
          end
        end
      end
    end
  end
end

::Google::Serverless::Exec::Tasks.define
