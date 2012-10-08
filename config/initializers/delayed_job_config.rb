Delayed::Worker.destroy_failed_jobs = false
Delayed::Worker.sleep_delay = 1
Delayed::Worker.max_attempts = 8
Delayed::Worker.max_run_time = 5.minutes
Delayed::Worker.read_ahead = 10
Delayed::Worker.delay_jobs = !Rails.env.test?