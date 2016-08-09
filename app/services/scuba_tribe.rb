class ScubaTribe
  attr_reader :partner_api_key, :client_api_key

  def initialize(client_api_key = '')
    @partner_api_key = Figaro.env.scuba_tribe_key
    @client_api_key = client_api_key
  end

  def signup(params)
    connection.post do |req|
      req.url '/v1/signup'
      req.body = params
    end.body
  end

  def heartbeat
    get('/v1/heartbeat')
  end

  def account
    get('/v1/account')
  end

  def profile
    get('/v1/profile')
  end

  def locations
    get('/v1/profile/locations')
  end

  def location(id)
    get("/v1/profile/location/#{id}")
  end

  def contacts
    get('/v1/profile/contacts')
  end

  def reviews(options = {})
    limit = 15
    get("/v1/reviews?limit=#{limit}&offset=#{(options[:page] - 1) * limit}")
  end

  def review(id)
    get("/v1/review/#{id}")
  end

  def accounts
    connection.get('/v1/accounts')
  end

  def requests(options = {})
    limit = 15
    get("/v1/requests?limit=#{limit}&offset=#{(options[:page] - 1) * limit}")
  end

  def request(id)
    get("/v1/request/#{id}")
  end

  def send_request(booking_id, customer = {})
    connection.post do |conn|
      conn.url '/v1/request'
      conn.headers['API-KEY'] = client_api_key
      conn.body = {
        booking_id: booking_id,
        email: customer[:email],
        first_name: customer[:given_name],
        last_name: customer[:family_name]
      }
    end
  end

  def get(url)
    connection.get do |conn|
      conn.url url
      conn.headers['API-KEY'] = client_api_key
    end.body
  end

  def connection
    @connection ||= ::Faraday.new(url: 'https://api.scubatribe.com') do |faraday|
      faraday.request  :url_encoded
      faraday.response :logger
      faraday.response :json
      faraday.adapter  Faraday.default_adapter
      faraday.headers['Accept'] = 'application/json'
      faraday.headers['API-KEY'] = partner_api_key
    end
  end
end
