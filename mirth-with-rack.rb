# Rack app and Rack Requests:
# * Transform Mirth into an application that
#   follows the Rack specifications and uses
#   Rack::Request to handle requests
# * Use Puma as an application server

require 'yaml/store'

# Require the relevant libraries
require 'rack/handler/puma'

app = -> environment {
  # Create an application Server and New Rack::Request Object
  request = Rack::Request.new(environment)

  store = YAML::Store.new("mirth.yml")

  # Use Built-in Rack::Response Methods
  if request.get? && request.path == "/show/birthdays"
    status = 200
    content_type = "text/html"
    response_message = "<body style='background: black; color: white;'>\n"
    response_message << "<ul>\n"

    # Get all the birthdays data in a hash object
    all_birthdays = {}
    store.transaction do
      all_birthdays = store[:birthdays]
    end

    all_birthdays.each do |birthday|
      response_message << "<li> #{birthday[:name]}</b> was born on #{birthday[:date]}!</li>\n"
    end

    response_message << "</ul>\n"
    response_message << <<~SRT
      <form action="/add/birthday" method="post" enctype="application/x-www-form-urlencoded">
        <p><label>Name <input type="text" name="name"></label></p>
        <p><label>Birthday <input type="date" name="date"></label></p>
        <p><button>Submit birthday</button></p>
      </form>
    SRT
    response_message << "</body>\n"
  elsif request.post? && request.path == "/add/birthday"
    status = 303
    content_type = "text/html"
    response_message = ""

    new_birthday = request.params

    # Store the user-input birthday data
    # back into the YAML store
    store.transaction do
      store[:birthdays] << new_birthday.transform_keys(&:to_sym)
    end
  else
    status = 200
    content_type = "text/plain"
    response_message = "Received a #{request.request_method} request to #{request.path}"
  end

  # Return 3-element Array
  headers = {
    'Content-Type' => "#{content_type}; charset=#{response_message.encoding.name}",
    "Location" => "/show/birthdays"
  }
  body = [response_message]
  [status, headers, body]
}

Rack::Handler::Puma.run(app, :Port => 1337, :Verbose => true)
