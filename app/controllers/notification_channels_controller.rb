class NotificationChannelsController < ApplicationController
  skip_forgery_protection only: :check
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

    if Rails.env.production? && request.format.html? && require_test_pass?(@notification_channel)
      flash.now[:alert] = "Please run and pass Send Test for the current settings before saving"
      return render :new, status: :unprocessable_entity
    end

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
    @notification_channel.assign_attributes(notification_channel_params)

    if Rails.env.production? && request.format.html? && require_test_pass?(@notification_channel)
      flash.now[:alert] = "Please run and pass Send Test for the current settings before saving"
      return render :edit, status: :unprocessable_entity
    end

    if @notification_channel.save
      respond_to do |format|
        format.html { redirect_to notification_channels_path, notice: "Channel was successfully updated." }
        format.json { render json: @notification_channel, status: :ok }
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
    end
  end

  def check
    kind = params.dig(:notification_channel, :kind)
    settings = params.dig(:notification_channel, :settings) || {}
    result = NotificationChannels::Validator.new.validate(kind: kind, settings: settings)

    respond_to do |format|
      format.json { render json: { ok: result.ok, message: result.message }, status: :ok }
      format.html { render template: "notification_channels/check_result_frame", locals: { result: result } }
      format.turbo_stream { render turbo_stream: turbo_stream.update("check_result", partial: "notification_channels/check_result", locals: { result: result }) }
    end
  end

  def test
    kind = params.dig(:notification_channel, :kind)
    settings = params.dig(:notification_channel, :settings) || {}
    tester = NotificationChannels::Tester.new
    result = tester.test(kind: kind, settings: settings, session_id: session.id.to_s)

    # For browser, render a snippet that will trigger Notification on client and then ACK
    if kind.to_s == "browser"
      token = result.settings_digest
      session[:last_test_pass] ||= {}
      session[:last_test_pass][token] = { ok: false, at: Time.now.utc.to_i }
      return render template: "notification_channels/browser_test_frame", locals: { settings_digest: token }
    end

    if result.ok
      mark_test_pass(result.settings_digest)
    end

    respond_to do |format|
      format.json { render json: { ok: result.ok, message: result.message, settings_digest: result.settings_digest }, status: :ok }
      format.html { render template: "notification_channels/check_result_frame", locals: { result: Struct.new(:ok, :message).new(result.ok, result.message) } }
      format.turbo_stream { render turbo_stream: turbo_stream.update("check_result", partial: "notification_channels/check_result", locals: { result: Struct.new(:ok, :message).new(result.ok, result.message) }) }
    end
  end

  def test_ack
    digest = params[:settings_digest].to_s
    mark_test_pass(digest)
    respond_to do |format|
      format.json { render json: { ok: true }, status: :ok }
      format.html { render template: "notification_channels/check_result_frame", locals: { result: Struct.new(:ok, :message).new(true, "Browser test confirmed") } }
      format.turbo_stream { render turbo_stream: turbo_stream.update("check_result", partial: "notification_channels/check_result", locals: { result: Struct.new(:ok, :message).new(true, "Browser test confirmed") }) }
    end
  end

  private

  def set_notification_channel
    @notification_channel = NotificationChannel.find(params[:id])
  end

  def notification_channel_params
    permitted = params.require(:notification_channel).permit(:kind, :enabled, settings: {})
    # Back-compat: support settings_json if provided
    if permitted[:settings].blank?
      raw = params.dig(:notification_channel, :settings_json)
      if raw.present?
        begin
          permitted[:settings] = JSON.parse(raw)
        rescue JSON::ParserError
          permitted[:settings] = {}
        end
      end
    end
    permitted
  end

  def settings_digest_for(channel)
    Digest::SHA256.hexdigest([channel.kind.to_s, (channel.settings || {}).to_json].join("|"))
  end

  def require_test_pass?(channel)
    # For persisted records, only require a test if settings will change
    if channel.persisted?
      return false unless channel.will_save_change_to_attribute?(:settings)
    end

    digest = settings_digest_for(channel)
    store = session[:last_test_pass] || {}
    entry = store[digest]
    return true if entry.nil?
    # require recent pass within 10 minutes
    passed_recently = entry[:ok] && (Time.now.utc.to_i - entry[:at].to_i) <= 600
    !passed_recently
  end

  def mark_test_pass(digest)
    session[:last_test_pass] ||= {}
    session[:last_test_pass][digest] = { ok: true, at: Time.now.utc.to_i }
  end
end
