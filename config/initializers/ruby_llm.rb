# RubyLLM.configure do |config|
  # config.openai_api_key = ENV["OPENAI_API_KEY"]
# end

RubyLLM.configure do |config|
  config.openai_api_key = ENV['OPENAI_API_KEY'] # Key for your endpoint
end
