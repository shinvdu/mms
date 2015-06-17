class NotificationsController < ApplicationController
  before_action :authenticate_account! #, except: [:show]
  before_action :set_notification, only: [:show, :destroy]
  before_action  only: [:show, :destroy] do 
    permission_access(:notification)
  end

  # GET /notifications
  # GET /notifications.json
  def index
    @notifications = Notification.where(user_id: current_user.uid).page(params[:page]).order(created_at: :desc)
    # @notifications = Notification.all
    @notifications_sort = {}
    @notifications.each do |n|
      date = n.created_at.strftime('%Y-%m-%d')
      if @notifications_sort[date].nil?
      @notifications_sort[date] = []
      end
      @notifications_sort[date]  << n
    end
  end

  # GET /notifications/unread
  # GET /notifications/unread.json
  def unread
    @notifications = Notification.where(user_id: current_user.uid).where(is_read: false).page(params[:page]).order(created_at: :desc)
  end

  # GET /notifications/1
  # GET /notifications/1.json
  def show
    @notification.is_read = true
    @notification.save!
    target_object = @notification.get_target_object
    object_name = @notification.target_type.underscore
    redirect_to send("#{object_name}_path",  target_object)
  end

  # DELETE /notifications/1
  # DELETE /notifications/1.json
  def destroy
    @notification.destroy
    respond_to do |format|
      format.html { redirect_to notifications_url, notice: 'Notification was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_notification
      @notification = Notification.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def notification_params
      params.require(:notification).permit(:user_id, :is_read, :title, :target_id, :target_type)
    end
end
