Delayed::Worker.logger = Logger.new(Rails.root.join('log', 'dj.log'))

Delayed::Worker.class_eval do
  def initialize(options = {})
    # options[:queues] = ['unnamed'] if options[:queues].blank?
    raise 'QUEUE or QUEUES is not set. Usage: QUEUE=[queue_name] rake jobs:work' if options[:queues].blank?
    p 'Running for queues: %s' % options[:queues].join(', ')
    if options[:queues].one? && options[:queues].first == 'local'
      options[:queues][0] = Rails.application.config.local_queue
      p 'Running for local queue: %s' % options[:queues].join(', ')
    end
    @quiet = options.key?(:quiet) ? options[:quiet] : true
    @failed_reserve_count = 0

    [:min_priority, :max_priority, :sleep_delay, :read_ahead, :queues, :exit_on_complete].each do |option|
      self.class.send("#{option}=", options[option]) if options.key?(option)
    end

    plugins.each { |klass| klass.new }
  end

  Rails.application.config.instance_eval do

    def get_local_queue_name
      '%s|%s' % [Socket.gethostname, server_pid]
    end

    def server_pid
      %w(player_unicorn upload_unicorn server).each do |f|
        path = Rails.root.join('tmp', 'pids', [f, 'pid'].join('.'))
        if File.exist? path
          File.open(path) do |file|
            return file.gets
          end
        end
      end
      raise 'System initializing error. Cannot initialize local queue name.'
    end
    def local_queue
      @local_queue = get_local_queue_name if @local_queue.blank?
      @local_queue
    end
  end
  puts '***********************************************'
  puts 'To start local delayed job worker'
  puts 'Use local queue: local'
  puts 'Ignore this message if you are running delayed_job worker'
  puts '***********************************************'
end

Delayed::Job.class_eval do
  before_save :set_local_queue

  def set_local_queue
    self.queue = Rails.application.config.local_queue if self.queue.blank? || self.queue == 'local'
  end
end

