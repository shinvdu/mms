#!/usr/bin/env ruby
require 'rubygems'
require 'sprockets'
require 'listen'

if ARGV[0] == '-h' || ARGV[0] == '--help'
	puts 'command [input_file] [output_file]'
	exit 0
end
environment = Sprockets::Environment.new
environment.append_path '.'
environment.append_path './css/'

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

def compile(env, input, output)
  File.delete output if File.exists?(output)
  bb = env.find_asset(input).to_s
  File.open(output, 'w') { |file| file.write(bb) }
end

# compile(environment, 'main.scss', '/mnt/app/mms/public/mms/css/main.css')
listener = Listen.to('.', './css/', only: /\.scss$/) do |modified, added, removed|
  puts "compiling file: #{modified}"
  filename = File.basename(modified[0], ".scss")
  dir = File.dirname(modified[0])
  input = "#{filename}.scss"
  puts  "input: #{input} "
  outfile = "#{dir}/#{filename}.css"
  puts  "ouput: #{outfile}"
  compile(input, outfile)
  puts '-------------------------------------------------------------'
  # puts "added absolute path: #{added}"
  # puts "removed absolute path: #{removed}"
end

listener.start # not blocking
sleep