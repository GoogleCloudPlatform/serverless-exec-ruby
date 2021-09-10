require "helper"

describe "rake task" do
  let(:simple_app_dir) { File.join __dir__, "simple-app" }

  it "displays usage" do
    Dir.chdir simple_app_dir do
      output = `rake serverless:exec --`
      assert_includes output, "This Rake task executes a given command in the context of a serverless"
    end
  end
end
