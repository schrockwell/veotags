defmodule VeotagsWeb.Helpers do
  def date(datetime) do
    Calendar.strftime(datetime, "%B %-d, %Y")
  end
end
