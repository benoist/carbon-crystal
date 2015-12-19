class RedirectionsController < ApplicationController
  before_action :redirect

  def to_new
    redirect_to "/new"
  end

  def to_google
    redirect_to "http://www.google.com"
  end

  def redirect
    Carbon.logger.debug "redirection"
  end
end
