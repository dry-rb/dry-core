RSpec.describe "fail on jruby on purpose" do
  it "fails on JRuby" do
    expect(RUBY_ENGINE).not_to eq("jruby"), "This test intentionally fails on JRuby"
  end
end
