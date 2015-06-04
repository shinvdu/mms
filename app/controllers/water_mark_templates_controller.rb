class WaterMarkTemplatesController < ApplicationController
  before_action :set_water_mark_template, only: [:show, :update, :destroy]
  before_action :set_refer_poses, only: [:index, :new, :create, :show]

  def index
    @water_mark_templates = WaterMarkTemplate.visible(current_user).all
  end

  def show
  end

  def new
    @water_mark_template = WaterMarkTemplate.new(:refer_pos => WaterMarkTemplate::REFER_POS::TR,
                                                 :font_size => 20,
                                                 :transparency => 70,
                                                 :status => WaterMarkTemplate::STATUS::CREATED,
                                                 :enabled => true)
  end

  def create
    @water_mark_template = WaterMarkTemplate.new(water_mark_template_params)

    respond_to do |format|
      if @water_mark_template.do_save
        format.html { redirect_to water_mark_templates_path, notice: 'Water mark template was successfully created.' }
        format.json { render :show, status: :created, location: @water_mark_template }
      else
        format.html { render :new }
        format.json { render json: @water_mark_template.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @water_mark_template.do_destroy
    respond_to do |format|
      format.html { redirect_to water_mark_templates_url, notice: 'Water mark template was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def set_water_mark_template
    @water_mark_template = WaterMarkTemplate.visible(current_user).find(params[:id])
  end

  def set_refer_poses
    @refer_poses = {
        '左上角' => WaterMarkTemplate::REFER_POS::TL,
        '右上角' => WaterMarkTemplate::REFER_POS::TR,
        '左下角' => WaterMarkTemplate::REFER_POS::BL,
        '右下角' => WaterMarkTemplate::REFER_POS::BR,
    }
  end

  def water_mark_template_params
    params[:water_mark_template][:owner_id] = current_user.owner.id
    params[:water_mark_template][:creator_id] = current_user.id
    params.require(:water_mark_template).permit(:owner_id, :creator_id, :name, :refer_pos, :text, :font_size, :transparency, :enabled)
  end
end
