#!/usr/bin/env ruby
require 'rubygems'
require 'sprockets'
if ARGV[0] == '-h' || ARGV[0] == '--help'
	puts 'command [input_file] [output_file]'
	exit 0
end
if not  (ARGV[0] && ARGV[1])
	puts 'command [input_file] [output_file]'
	exit 
end

input = ARGV[0]
output = ARGV[1]
 
environment = Sprockets::Environment.new
environment.append_path '.'

environment.context_class.class_eval do
  def asset_path(path, options = {})
  	if options[:type] == :image
  		return     "'../images/#{path}'"
  	end
  	# "assets/#{path}"
  	# "assets/#{path}"
  	"'../#{options[:type]}s/#{path}'"
  end
end

File.delete output if File.exists?(output)

bb = environment.find_asset(input).to_s

File.open(output, 'w') { |file| file.write(bb) }

