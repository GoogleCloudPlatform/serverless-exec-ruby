PROJECT_NAME = "ruby-serverless-ci-1"
INTEGRATION_PATH = File.join context_directory, "integration"

tool "deploy" do
  include :exec, e: true

  def run
    exec_tool ["integration", "deploy", "gae-standard"]
    exec_tool ["integration", "deploy", "gae-flexible"]
    exec_tool ["integration", "deploy", "cloud-run"]
  end

  tool "gae-standard" do
    include :exec, e: true

    def run
      Dir.chdir File.join INTEGRATION_PATH, "gae-standard-app"
      exec ["gcloud", "app", "deploy", "-q",
            "--project=#{PROJECT_NAME}"]
    end
  end

  tool "gae-flexible" do
    include :exec, e: true

    def run
      Dir.chdir File.join INTEGRATION_PATH, "gae-flexible-app"
      exec ["gcloud", "app", "deploy", "-q",
            "--project=#{PROJECT_NAME}"]
    end
  end

  tool "cloud-run" do
    include :exec, e: true

    def run
      Dir.chdir File.join INTEGRATION_PATH, "cloud-run-app"
      exec ["gcloud", "builds", "submit", "-q",
            "--project=#{PROJECT_NAME}",
            "--tag=gcr.io/#{PROJECT_NAME}/serverless-exec-cloud-run",
            "."]
      exec ["gcloud", "run", "deploy", "-q",
            "--project=#{PROJECT_NAME}",
            "--platform=managed",
            "--region=us-central1",
            "--allow-unauthenticated",
            "--image=gcr.io/#{PROJECT_NAME}/serverless-exec-cloud-run",
            "serverless-exec-cloud-run"]
    end
  end
end
