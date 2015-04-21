class FileDataController < ApplicationController
  def create
    require 'fileutils' #ruby老版本可尝试改为 require 'ftools'
    tmp = params[:fileData][:myfile]
    file = File.join("public", tmp.original_filename)
    FileUtils.cp tmp.path, file
    render :action => :index
  end

  def index
  end

end
