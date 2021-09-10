require "helper"

describe "rake task" do
  let(:project_name) { "ruby-serverless-ci-1" }
  let(:gae_standard_app_dir) { File.join __dir__, "gae-standard-app" }
  let(:gae_flexible_app_dir) { File.join __dir__, "gae-flexible-app" }
  let(:cloud_run_app_dir) { File.join __dir__, "cloud-run-app" }

  it "runs a job on app engine standard" do
    Dir.chdir gae_standard_app_dir do
      output = `EXEC_PROJECT=#{project_name} rake serverless:exec -- cat app.rb`
      assert_includes output, "# SINATRA_SOURCE: gae-standard-app"
    end
  end

  it "runs a job on app engine flexible" do
    Dir.chdir gae_flexible_app_dir do
      output = `EXEC_PROJECT=#{project_name} rake serverless:exec -- cat app.rb`
      assert_includes output, "# SINATRA_SOURCE: gae-flexible-app"
    end
  end

  it "runs a job on cloud run" do
    Dir.chdir cloud_run_app_dir do
      env = "EXEC_PROJECT=#{project_name} EXEC_SERVICE_NAME=serverless-exec-cloud-run EXEC_REGION=us-central1"
      output = `#{env} rake serverless:exec -- cat app.rb`
      assert_includes output, "# SINATRA_SOURCE: cloud-run-app"
    end
  end
end
