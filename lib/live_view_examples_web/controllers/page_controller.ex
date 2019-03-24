defmodule LiveViewExamplesWeb.PageController do
  use LiveViewExamplesWeb, :controller

  def index(conn, _) do
    render(conn, "observer.html")
  end
end
