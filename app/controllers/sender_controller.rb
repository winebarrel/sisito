class SenderController < ApplicationController
  before_action :set_select_from_options, only: [:index, :create]

  def index
    @confirmation_mail = ConfirmationMail.new
    @confirmation_mail.from = params[:from]
    @confirmation_mail.to = params[:to]

    if @confirmation_mail.to.blank? and params[:digest].present?
      bounce_mail = BounceMail.where(digest: params[:digest]).take
      @confirmation_mail.to = bounce_mail.recipient if bounce_mail.present?
    end
  end

  require 'net/smtp'
  def create
    @confirmation_mail = ConfirmationMail.new(confirmation_mail_params)

    if @confirmation_mail.save
      algorithm = Rails.application.config.sisito.fetch(:digest)
      digest = algorithm.hexdigest(@confirmation_mail.to.strip)
      redirect_to sent_path(digest: digest), notice: 'Confirmation mail was successfully sent.'
    else
      render :index
    end
  rescue Net::SMTPError => e
    flash.now[:error] = e.message
    render :index
  end

  def sent
    @digest = params[:digest]

    unless @digest
      redirect_to root_path
    end
  end

  private

  def set_select_from_options
    @select_from_options = Rails.application.config.sisito.fetch(:smtp).keys
  end

  def confirmation_mail_params
    params.require(:confirmation_mail).permit(:from, :to, :subject, :body)
  end
end
