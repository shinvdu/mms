# == Schema Information
#
# Table name: water_mark_templates
#
#  id                            :integer          not null, primary key
#  owner_id                      :integer
#  creator_id                    :integer
#  name                          :string(255)
#  width                         :integer
#  height                        :integer
#  refer_pos                     :string(255)
#  text                          :string(255)
#  img                           :string(255)
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#  aliyun_water_mark_template_id :string(255)
#  status                        :integer          default(10)
#  font_size                     :integer
#  transparency                  :integer
#

class WaterMarkTemplate < ActiveRecord::Base
  scope :visible, -> (user) { where(:owner => user.owner, :disabled => false) }
  belongs_to :owner, :class_name => 'User'
  belongs_to :creator, :class_name => 'User'
  has_many :enabled_water_marks
  validates :name, presence: true
  validates :text, presence: true
  validates :refer_pos, :inclusion => {:in => %w(TopRight TopLeft BottomRight BottomLeft), :message => "%{value} is not a valid position"}
  validates :font_size, :numericality => {:only_integer => true, :greater_than_or_equal_to => 10, :less_than_or_equal_to => 30}
  validates :transparency, :numericality => {:only_integer => true, :greater_than_or_equal_to => 0, :less_than_or_equal_to => 100}
  mount_uploader :img, WaterMarkUploader
  include MTSWorker::WaterMarkTemplateWorker

  attr_accessor :enabled

  module STATUS
    CREATED = 10
    READY = 20
  end
  module REFER_POS
    TR = 'TopRight'
    TL = 'TopLeft'
    BR = 'BottomRight'
    BL = 'BottomLeft'
  end

  def do_save
    transaction do
      if self.save
        self.delay.create_img_and_upload
        self.enable if self.enabled
        true
      else
        false
      end
    end
  end

  def enable
    self.creator.enabled_water_mark.water_mark_template = self
    self.creator.enabled_water_mark.save!
  end

  def stop
    self.creator.enabled_water_mark.water_mark_template = nil
    self.creator.enabled_water_mark.save!
  end

  def do_destroy
    transaction do
      self.enabled_water_marks.each do |enabled_water_mark|
        enabled_water_mark.water_mark_template = nil
        enabled_water_mark.save!
      end
      self.disabled = true
      self.delay.remove_from_aliyun_and_self
      self.save!
    end
  end

  def remove_from_aliyun_and_self
    self.img.remove!
    self.delete_aliyun_water_mark_template if self.aliyun_water_mark_template_id.present?
    self.destroy!
  end

  def create_img_and_upload
    font_size = self.font_size
    images = Magick::Image.read('caption:%s' % self.text) do
      self.size = '2000x'
      self.pointsize = font_size
      self.font = 'Arial'
      self.fill = '#bfbfbf'
      self.background_color = 'Transparent'
    end
    image = images[0]
    tmp_file_path = Rails.root.join('tmp', UUIDTools::UUID.random_create.to_s << '.png').to_s
    image.trim!
    image.write tmp_file_path
    self.width = image.columns
    self.height = image.rows
    `convert #{tmp_file_path} -channel A -fx "A*#{(100.0 - self.transparency) / 100}" #{tmp_file_path}`
    File.open(tmp_file_path) { |f| self.img = f }
    add_aliyun_water_mark_template
    self.status = STATUS::READY
    self.save!
    FileUtils.rm tmp_file_path
    # tmp_file_path
  end
end
