module Log4r
  class Logger
    def formatter()
    end
  end

  # monkey patch log4r for better trace
  PatternFormatter::DirectiveTable['T'] =
      '(event.tracer.nil? ? "no trace" : event.tracer[0].split(File::SEPARATOR).last(3).join(File::SEPARATOR))'

  Rails.logger.outputters.each do |outputter|
    PatternFormatter.create_format_methods(outputter.formatter)
  end

end

Delayed::Worker.class_eval do
  def self.logger
    Log4r::Logger['delayed_job']
  end

  def logger
    Log4r::Logger['delayed_job']
  end
end

Delayed::Job.class_eval do
  def self.logger
    Log4r::Logger['delayed_job_query']
  end

  def logger
    Log4r::Logger['delayed_job_query']
  end
end

