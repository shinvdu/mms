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
  belongs_to :owner, :class_name => 'User'
  belongs_to :creator, :class_name => 'User'
  validates :name, presence: true
  validates :text, presence: true
  validates :refer_pos, :inclusion => {:in => %w(TopRight TopLeft BottomRight BottomLeft), :message => "%{value} is not a valid position"}
  validates :font_size, :numericality => {:only_integer => true, :greater_than_or_equal_to => 3, :less_than_or_equal_to => 20}
  validates :transparency, :numericality => {:only_integer => true, :greater_than_or_equal_to => 0, :less_than_or_equal_to => 100}
  mount_uploader :img, WaterMarkUploader
  include Privilege
  include MTSWorker::WaterMarkTemplateWorker

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
    if self.save
      self.delay.create_img_and_upload
    else
      false
    end
  end

  def create_img_and_upload
    font_size = self.font_size
    image = Magick::Image.read('caption:%s' % self.text) do
      self.size = '2000x'
      self.pointsize = font_size
      self.font = 'Arial'
      self.background_color = 'Transparent'
    end
    tmp_file_path = Rails.root.join('tmp', UUIDTools::UUID.random_create.to_s << '.png').to_s
    image[0].trim!
    image[0].write tmp_file_path
    self.width = images[0].columns
    self.height = images[0].rows
    `convert #{tmp_file_path} -channel A -fx "A*#{(100.0 - self.transparency) / 100}" #{tmp_file_path}`
    File.open(tmp_file_path) { |f| self.img = f }
    self.save!
    add_aliyun_water_mark_template
    FileUtils.rm tmp_file_path
    # tmp_file_path
  end
end
