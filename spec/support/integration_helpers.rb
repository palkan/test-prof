# frozen_string_literal: true

module IntegrationHelpers
  def run_rspec(path, chdir: nil, success: true, env: {}, options: "")
    output, status = Open3.capture2(
      env,
      "bundle exec rspec #{options} #{path}_fixture.rb",
      chdir: chdir || File.expand_path("../../integrations/fixtures/rspec", __FILE__)
    )
    expect(status).to be_success, "Test #{path} failed with: #{output}" if success
    warn output if output.match?(/warning:/i)
    output
  end

  def run_minitest(path, chdir: nil, success: true, env: {})
    output, status = Open3.capture2(
      env,
      "bundle exec ruby #{path}_fixture.rb #{env["TESTOPTS"]}",
      chdir: chdir || File.expand_path("../../integrations/fixtures/minitest", __FILE__)
    )
    expect(status).to be_success, "Test #{path} failed with: #{output}" if success
    warn output if output.match?(/warning:/i)
    output
  end

  def run_rubocop(path, cop:)
    fullpath = File.join(__dir__, "../integrations/fixtures/rubocop", "#{path}_fixture.rb")
    test_prof_lib = File.join(__dir__, "../../lib")

    output, _status = Open3.capture2(
      {"RUBYOPT" => "-I#{test_prof_lib}"},
      "rubocop -r test_prof/rubocop.rb --force-default-config --only #{cop} #{fullpath} 2>&1"
    )
    warn output if output.match?(/warning:/i)
    output
  end
end
