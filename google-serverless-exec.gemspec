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

lib = File.expand_path "lib", __dir__
$LOAD_PATH.unshift lib unless $LOAD_PATH.include? lib
require "google/serverless/exec/version"
version = ::Google::Serverless::Exec::VERSION

::Gem::Specification.new do |spec|
  spec.name = "google-serverless-exec"
  spec.version = version
  spec.authors = ["Daniel Azuma", "Tram Bui"]
  spec.email = ["dazuma@gmail.com", "trambui09098@gmail.com"]

  spec.summary = "Execute production tasks for Google Serverless apps"
  spec.description =
    "The google-serverless-exec gem provides a way to safely run production" \
    " maintenance tasks, such as database migrations, for your serverless" \
    " applications deployed to Google App Engine or Google Cloud Run."
  spec.license = "Apache-2.0"
  spec.homepage = "https://github.com/GoogleCloudPlatform/serverless-exec-ruby"

  spec.files = ::Dir.glob("lib/**/*.rb") +
               ::Dir.glob("data/**/*") +
               ::Dir.glob("*.md") +
               ["LICENSE", ".yardopts"]
  spec.required_ruby_version = ">= 2.5.0"
  spec.require_paths = ["lib"]

  spec.add_development_dependency "google-style", "~> 1.25.1"
  spec.add_development_dependency "minitest", "~> 5.11"
  spec.add_development_dependency "minitest-focus", "~> 1.1"
  spec.add_development_dependency "minitest-rg", "~> 5.2"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rdoc", "~> 6.0"
  spec.add_development_dependency "redcarpet", "~> 3.4"
  spec.add_development_dependency "yard", "~> 0.9"

  if spec.respond_to? :metadata
    spec.metadata["changelog_uri"] = "https://www.rubydoc.info/gems/google-serverless-exec/#{version}/file/CHANGELOG.md"
    spec.metadata["source_code_uri"] = "https://github.com/GoogleCloudPlatform/serverless-exec-ruby"
    spec.metadata["bug_tracker_uri"] = "https://github.com/GoogleCloudPlatform/serverless-exec-ruby/issues"
    spec.metadata["documentation_uri"] = "https://www.rubydoc.info/gems/google-serverless-exec/#{version}"
  end
end
