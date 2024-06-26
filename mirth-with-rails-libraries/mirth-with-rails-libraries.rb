require 'rack/handler/puma'
require 'rack'

# Rails libraries
require 'action_dispatch'
require 'action_controller'
require 'active_record'

# Create a connection between AR and the database
ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: "../mirth.sqlite3")

# Create A AR model for the birthdays
class Birthday < ActiveRecord::Base; end

# Ensure the Action Controller reads views from root
ActionController::Base.prepend_view_path("./views")

# Create a controller for birthdays
class BirthdaysController < ActionController::Base
  def index
    @all_birthdays = Birthday.all
  end

  def create
    Birthday.create(name: params['name'], date: params["date"])
    redirect_to(birthdays_path, status: :see_other)
  end

  def all_paths
    render(plain: "Received a #{request.request_method} request to #{request.path}")
  end
end

# Create a router to manage endpoints
router = ActionDispatch::Routing::RouteSet.new

# Inblude url helpers module to use `birthdays_path`
BirthdaysController.include(router.url_helpers)

router.draw do
  # Creates standardised CRUD routes mapped to the controller
  resources :birthdays

  # Routes all paths to `birthdays#all_paths` action method
  match '*path', via: :all, to: 'birthdays#all_paths'
end

Rack::Handler::Puma.run(router, :Port => 1337, :Verbose => true)
