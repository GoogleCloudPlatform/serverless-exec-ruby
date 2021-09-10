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


module Google
  module Serverless
    class Exec
      ##
      # A Railtie that automatically adds the serverless:exec rake task.
      #
      # This Railtie is loaded automatically if this gem is included in a
      # Rails app. You may opt out by including the following line in your
      # Rails configuration:
      #
      #     config.google_serverless.define_exec_task = false
      #
      class Railtie < ::Rails::Railtie
        config.google_serverless = ::ActiveSupport::OrderedOptions.new
        config.google_serverless.define_exec_task = true

        rake_tasks do |app|
          require "google/serverless/exec/tasks" if app.config.google_serverless.define_exec_task
        end
      end
    end
  end
end
