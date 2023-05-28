class ApplicationController < ActionController::Base
  # add_flash_types :info, :error, :warning, :danger, :success
  include Pagy::Backend

end
