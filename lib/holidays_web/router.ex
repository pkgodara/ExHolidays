defmodule HolidaysWeb.Router do
  use HolidaysWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {HolidaysWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", HolidaysWeb do
    pipe_through :api
    # TODO:: No Auth

    get "/", HolidaysController, :index
    get "/calendar", HolidaysController, :calendar
    post "/", HolidaysController, :create
  end
end
