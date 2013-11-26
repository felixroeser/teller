class BoxNetAuthsController < ApplicationController
  def index
    ap params

    render status: :accepted, nothing: true
  end
end