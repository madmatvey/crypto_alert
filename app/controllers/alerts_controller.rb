class AlertsController < ApplicationController
  before_action :set_alert, only: %i[show edit update destroy]

  def index
    @alerts = Alert.order(created_at: :desc)
    respond_to do |format|
      format.html
      format.json { render json: @alerts }
    end
  end

  def show
    respond_to do |format|
      format.html
      format.json { render json: @alert }
    end
  end

  def new
    @alert = Alert.new
  end

  def edit; end

  def create
    @alert = Alert.new(alert_params)
    if @alert.save
      respond_to do |format|
        format.html { redirect_to alerts_path, notice: "Alert was successfully created." }
        format.json { render json: @alert, status: :created }
      end
    else
      respond_to do |format|
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: { errors: @alert.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  def update
    if @alert.update(alert_params)
      respond_to do |format|
        format.html { redirect_to @alert, notice: "Alert was successfully updated." }
        format.json { render json: @alert, status: :ok }
        format.turbo_stream
      end
    else
      respond_to do |format|
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: { errors: @alert.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @alert.destroy
    respond_to do |format|
      format.html { redirect_to alerts_url, notice: "Alert was successfully destroyed." }
      format.json { head :no_content }
      format.turbo_stream
    end
  end

  private

  def set_alert
    @alert = Alert.find(params[:id])
  end

  def alert_params
    params.require(:alert).permit(:symbol, :direction, :threshold_price, :active)
  end
end
