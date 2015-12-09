class RedirectionsController < ApplicationController
  def to_new
    redirect_to "/new"
  end

  def to_google
    redirect_to "http://www.google.com"
  end
end
