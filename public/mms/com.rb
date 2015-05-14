#!/usr/bin/env ruby
require 'rubygems'
require 'sprockets'

input = 'tian.scss' 
output = 'tian.css'
 
environment = Sprockets::Environment.new
environment.append_path '.'

environment.context_class.class_eval do
  def asset_path(path, options = {})
  	puts options
  	if options[:type] == :image
  		return     "images/#{path}"
  	end
  	# "assets/#{path}"
  	"assets/#{path}"
  end
end

File.delete output if File.exists?(output)

bb = environment.find_asset(input).to_s

File.open(output, 'w') { |file| file.write(bb) }

