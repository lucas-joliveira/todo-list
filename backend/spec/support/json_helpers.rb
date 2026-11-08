module JsonHelpers
  # Corpo da resposta já convertido de JSON para Hash/Array.
  def json
    response.parsed_body
  end
end

RSpec.configure do |config|
  config.include JsonHelpers, type: :request
end
