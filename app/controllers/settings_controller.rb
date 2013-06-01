class SettingsController < ApplicationController

  before_filter :authenticate_payer!

  def index
    @settings = current_payer.settings
  end

  private


end
