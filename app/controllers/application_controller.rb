class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Use null session for AJAX/API requests, verify token for forms
  protect_from_forgery with: :null_session
end
