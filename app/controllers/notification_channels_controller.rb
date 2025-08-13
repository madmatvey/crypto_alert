class NotificationChannelsController < ApplicationController
  before_action :set_notification_channel, only: %i[show edit update destroy]

  def index
    @notification_channels = NotificationChannel.order(created_at: :desc)
    respond_to do |format|
      format.html
      format.json { render json: @notification_channels }
    end
  end

  def show
    respond_to do |format|
      format.html
      format.json { render json: @notification_channel }
    end
  end

  def new
    @notification_channel = NotificationChannel.new
  end

  def edit; end

  def create
    @notification_channel = NotificationChannel.new(notification_channel_params)
    if @notification_channel.save
      respond_to do |format|
        format.html { redirect_to notification_channels_path, notice: "Channel was successfully created." }
        format.json { render json: @notification_channel, status: :created }
      end
    else
      respond_to do |format|
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: { errors: @notification_channel.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  def update
    if @notification_channel.update(notification_channel_params)
      respond_to do |format|
        format.html { redirect_to @notification_channel, notice: "Channel was successfully updated." }
        format.json { render json: @notification_channel, status: :ok }
        format.turbo_stream
      end
    else
      respond_to do |format|
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: { errors: @notification_channel.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @notification_channel.destroy
    respond_to do |format|
      format.html { redirect_to notification_channels_url, notice: "Channel was successfully destroyed." }
      format.json { head :no_content }
      format.turbo_stream
    end
  end

  private

  def set_notification_channel
    @notification_channel = NotificationChannel.find(params[:id])
  end

  def notification_channel_params
    permitted = params.require(:notification_channel).permit(:kind, :enabled, :settings_json)
    settings = begin
      JSON.parse(permitted.delete(:settings_json).presence || "{}")
    rescue JSON::ParserError
      {}
    end
    permitted[:settings] = settings
    permitted
  end
end
