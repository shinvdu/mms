require 'logger'
# log_file = File.open("log/debug.log", "a")
# Logger.new MultiIO.new(STDOUT, log_file)
log = Logger.new STDOUT
Rails.logger = log
Delayed::Worker.logger = log
