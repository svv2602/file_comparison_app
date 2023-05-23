module ApplicationHelper
  include Pagy::Frontend
  def format_datetime(datetime,long = false )
    if long
      datetime.strftime('%d-%m-%Y %H:%M:%S')
    else
      datetime.strftime('%d-%m-%Y')
    end
  end
end
