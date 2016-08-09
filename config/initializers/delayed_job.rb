if Rails.env.development?
  Delayed::Worker.delay_jobs = false
end
