# require File.dirname(__FILE__) + '/spec_helper'
require "open-uri"
require "net/http"

class FileDataController < ApplicationController
  def create
    require 'fileutils'
    uploadedFile = params[:fileData][:myfile]
    fileType = params[:fileData][:fileType]

    if !['original_video'].include? fileType
      return render :json => 'invalid file type'
    end

    videoDetail = VideoDetail.new(:video => uploadedFile)
    videoDetail.save!

    render :json => 'succeed'
  end

  def index
  end
end
