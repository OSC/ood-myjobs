class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  before_action :set_locale

  def set_locale
    I18n.locale = ::Configuration.locale
  rescue I18n::InvalidLocale => e
    logger.warn "I18n::InvalidLocale #{::Configuration.locale}: #{e.message}"
  rescue NoMethodError => e
    if ! ::Configuration.locales_root.exist?
      logger.warn "I18n failure: configured locale root #{::Configuration.locales_root} does not exist"
    else
      raise e
    end
  end
end
