desc "booting system for testing"
task :boot  => :environment do
	puts eval(ENV['code'])
end
