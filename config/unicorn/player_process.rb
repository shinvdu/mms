processes = ENV['PROCESSES'] || 15
worker_processes processes.to_i

app_root = File.expand_path("../../..", __FILE__)
working_directory app_root
users = ENV['USER'] || 'www-data'
user "#{users}", "#{users}"

# Listen on fs socket for better performance
# listen "/tmp/upload_unicorn.sock", :backlog => 64
port = ENV['PORT'] || 4096
listen port.to_i #, :tcp_nopush => false


# Nuke workers after 30 seconds instead of 60 seconds (the default)
timeout 30

# App PID
pid "#{app_root}/tmp/pids/player_unicorn.pid"

# By default, the Unicorn logger will write to stderr.
# Additionally, some applications/frameworks log to stderr or stdout,
# so prevent them from going to /dev/null when daemonized here:
stderr_path "#{app_root}/log/unicorn.stderr.log"
stdout_path "#{app_root}/log/unicorn.stdout.log"

# To save some memory and improve performance
preload_app true

before_fork do |server, worker|
  # 参考 http://unicorn.bogomips.org/SIGNALS.html
  # 使用USR2信号，以及在进程完成后用QUIT信号来实现无缝重启
  old_pid = app_root + '/tmp/pids/player_unicorn.pid.oldbin'
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # someone else did our job for us
    end
  end

  # the following is highly recomended for Rails + "preload_app true"
  # as there's no need for the master process to hold a connection
  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.connection.disconnect!
end

after_fork do |server, worker|
  # 禁止GC，配合后续的OOB，来减少请求的执行时间
  # GC.disable
  # the following is *required* for Rails + "preload_app true",
  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.establish_connection
end