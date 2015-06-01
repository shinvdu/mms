module LocalVideoWorker
  module Scheduled
    require 'fileutils'

    # used in scheduled_worker, currently not under using
    def process_video_product_task
      VideoProductTask.not_finished.each do |task|
        task.process
      end
    end
  end
end