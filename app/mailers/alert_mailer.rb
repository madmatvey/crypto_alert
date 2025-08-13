# frozen_string_literal: true

class AlertMailer < ApplicationMailer
  default from: ENV.fetch("ALERTS_FROM", "alerts@example.com")

  def alert_email
    @body = params[:body]
    mail(to: params[:to], subject: params[:subject]) do |format|
      format.text { render plain: @body }
    end
  end
end
