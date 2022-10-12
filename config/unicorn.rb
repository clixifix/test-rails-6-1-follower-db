# frozen_string_literal: true

require 'fileutils'

if ENV['RACK_ENV'] == 'production'
  listen '/tmp/nginx.socket'
else
  listen ENV.fetch('PORT', 3000)
end

# need :tcp_nopush => false 	# for streaming
# see https://gist.github.com/nathany/5058140 for more info
# nb backlog has a minimum size of 16 iirc
# listen ENV['PORT'], :backlog => Integer(ENV['UNICORN_BACKLOG'] || 32), :tcp_nopush => false

worker_processes (ENV['unicorn_workers'] || 3).to_i # number of unicorn workers to spin up

timeout (ENV['unicorn_timeout'] || 60).to_i # restarts workers that don't return after X seconds

# ----------------------------------------
# playing with preload-app

# combine Ruby 2.0.0dev or REE with "preload_app true" for memory savings
# http://rubyenterpriseedition.com/faq.html#adapt_apps_for_cow
preload_app ENV['RAILS_ENV'] == 'production' # Only needs to be true for production. Probably.
# GC.respond_to?(:copy_on_write_friendly=) and
# GC.copy_on_write_friendly = true

before_fork do |_server, _worker|
  FileUtils.touch('/tmp/app-initialized')
  Signal.trap 'TERM' do
    ## fails with
    # master loop error: uninitialized constant #<Class:#<Unicorn::Configurator:0x0000561011d0f148>>::Rails (NameError)
    # Rails.logger.info 'Unicorn master intercepting TERM and sending myself QUIT instead'
    Process.kill 'QUIT', Process.pid
  end

  # the following is highly recomended for Rails + "preload_app true"
  # as there's no need for the master process to hold a connection
  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.connection.disconnect!

  MessagesBrokerManager.disconnect if ENV['INTEGRATION_TIER_ENABLED'] == 'true'

  # The following is only recommended for memory/DB-constrained
  # installations.  It is not needed if your system can house
  # twice as many worker_processes as you have configured.
  #
  # # This allows a new master process to incrementally
  # # phase out the old master process with SIGTTOU to avoid a
  # # thundering herd (especially in the "preload_app false" case)
  # # when doing a transparent upgrade.  The last worker spawned
  # # will then kill off the old master process with a SIGQUIT.
  # old_pid = "#{server.config[:pid]}.oldbin"
  # if old_pid != server.pid
  #   begin
  #     sig = (worker.nr + 1) >= server.worker_processes ? :QUIT : :TTOU
  #     Process.kill(sig, File.read(old_pid).to_i)
  #   rescue Errno::ENOENT, Errno::ESRCH
  #   end
  # end
  #
  # Throttle the master from forking too quickly by sleeping.  Due
  # to the implementation of standard Unix signal handlers, this
  # helps (but does not completely) prevent identical, repeated signals
  # from being lost when the receiving process is busy.
  # sleep 1
end

after_fork do |_server, _worker|
  # per-process listener ports for debugging/admin/migrations
  # addr = "127.0.0.1:#{9293 + worker.nr}"
  # server.listen(addr, :tries => -1, :delay => 5, :tcp_nopush => true)

  Signal.trap 'TERM' do
    # Rails.logger.info 'Unicorn worker intercepting TERM and doing nothing. Wait for master to sent QUIT'

    MessagesBrokerManager.disconnect if ENV['INTEGRATION_TIER_ENABLED'] == 'true'
  end

  # the following is *required* for Rails + "preload_app true",
  # more details added from https://devcenter.heroku.com/articles/concurrency-and-database-connections
  if defined?(ActiveRecord::Base)
    config = Rails.application.config.database_configuration[Rails.env]
    Rails.logger.error "¬¬ config 1: #{config}"
    config = config['primary'] if ENV.fetch('FOLLOWERUSER_URL', nil).present?
    Rails.logger.error "¬¬ config 2: #{config}" if ENV.fetch('FOLLOWERUSER_URL', nil).present?

    ActiveRecord::Base.establish_connection(config)
  end

  MessagesBrokerManager.connect(ENV.fetch('CLOUDAMQP_URL')) if ENV.fetch('INTEGRATION_TIER_ENABLED', nil) == 'true'

  # if preload_app is true, then you may also want to check and
  # restart any other shared sockets/descriptors such as Memcached,
  # and Redis.  TokyoCabinet file handles are safe to reuse
  # between any number of forked children (assuming your kernel
  # correctly implements pread()/pwrite() system calls)
end
