class Rack::Attack

  ### Configure Cache ###

  # If you don't want to use Rails.cache (Rack::Attack's default), then
  # configure it here.
  #
  # Note: The store is only used for throttling (not blacklisting and
  # whitelisting). It must implement .increment and .write like
  # ActiveSupport::Cache::Store

  # Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new

  ### Throttle Spammy Clients ###

  # If any single client IP is making tons of requests, then they're
  # probably malicious or a poorly-configured scraper. Either way, they
  # don't deserve to hog all of the app server's CPU. Cut them off!
  #
  # Note: If you're serving assets through rack, those requests may be
  # counted by rack-attack and this throttle may be activated too
  # quickly. If so, enable the condition to exclude them from tracking.

  # Throttle all requests by IP (60rpm)
  #
  # Key: "rack::attack:#{Time.now.to_i/:period}:req/ip:#{req.ip}"
  throttle('req/ip', :limit => 300, :period => 5.minutes) do |req|
    req.ip # unless req.path.starts_with?('/assets')
  end

  ### Prevent Brute-Force Login Attacks ###

  # The most common brute-force login attack is a brute-force password
  # attack where an attacker simply tries a large number of emails and
  # passwords to see if any credentials match.
  #
  # Another common method of attack is to use a swarm of computers with
  # different IPs to try brute-forcing a password for a specific account.

  # Throttle POST requests to /login by IP address
  #
  # Key: "rack::attack:#{Time.now.to_i/:period}:logins/ip:#{req.ip}"
  throttle('logins/ip', :limit => 5, :period => 20.seconds) do |req|
    if req.path == '/users/sign_in' && req.post?
      req.ip
    end
  end

  # Throttle POST requests to /login by email param
  #
  # Key: "rack::attack:#{Time.now.to_i/:period}:logins/email:#{req.email}"
  #
  # Note: This creates a problem where a malicious user could intentionally
  # throttle logins for another user and force their login requests to be
  # denied, but that's not very common and shouldn't happen to you. (Knock
  # on wood!)
  throttle("logins/email", :limit => 5, :period => 20.seconds) do |req|
    if req.path == '/users/sign_in' && req.post?
      # return the email if present, nil otherwise
      req.params['email'].presence
    end
  end

  ### Custom Throttle Response ###

  # By default, Rack::Attack returns an HTTP 429 for throttled responses,
  # which is just fine.
  #
  # If you want to return 503 so that the attacker might be fooled into
  # believing that they've successfully broken your app (or you just want to
  # customize the response), then uncomment these lines.
  self.throttled_response = lambda do |env|
   [ 429,  # status
     {},   # headers
     ['
      <html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
      <head>
        <meta http-equiv="content-type" content="text/html; charset=UTF-8">
        <title>Client Throttled: 429</title>
        <style>
        html { background:#efefef; }
        body { background:#efefef;font-family:Arial, Verdana, sans-serif; font-size:12px;}
        #header { text-align:center; margin-top:50px;}
        #content { width:650px; border:4px solid #e81717; margin:auto; margin-top:50px; background:#fff;margin-bottom:50px; -moz-box-shadow: 0 0 20px #ff5151; -webkit-box-shadow: 0 0 20px #ff5151; box-shadow: 0 0 20px #ff5151;}
        #content .inner { padding:20px;}
        #content h2 { font-size:180%; margin-bottom:10px;}
        #content h2 span { background:#FFFBC6; padding:1px;}
        #content p.intro { font-size:120%; line-height:1.5; margin:10px 0;}
        #content div.logo { float:right;}
        #content ul.list {  font-size:110%; background:#f7f7f7; padding:10px; width: 55%;}
        #content ul.list li { list-style:disc;  line-height:1.5; margin-left:20px;}
        #content a { color:#111;}
        </style>
      </head>
      <body>
        <div id="content">
          <div class="inner">
            <h2><span>Your client has been temporarily blocked...</span></h2>
            <p class="intro">You have been throttled for making too many requests in a short period of time.</p>
          </div>
        </div>
      </body>
      </html>
     ']] # body
  end
end
