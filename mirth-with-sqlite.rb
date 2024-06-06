# Rack app and Rack Requests:
# * Transform Mirth into an application that
#   follows the Rack specifications and uses
#   Rack::Request to handle requests
# * Use Puma as an application server
require 'sqlite3'

# Require the relevant libraries
require 'rack/handler/puma'
require 'rack'

app = -> environment {
  # Create an application Server and New Rack::Request Object
  request = Rack::Request.new(environment)
  response = Rack::Response.new

  database = SQLite3::Database.new("mirth.sqlite3", results_as_hash: true)

  # Use Built-in Rack::Response Methods
  if request.get? && request.path == "/show/birthdays"
    response.content_type = "text/html; charset=UTF-8"
    response.write "<body style='background: black; color: white;'>\n"
    response.write "<ul>\n"

    # Get all the birthdays from the database
    all_birthdays = database.execute("SELECT * FROM birthdays")

    all_birthdays.each do |birthday|
      p birthday
      response.write "<li> #{birthday["name"]}</b> was born on #{birthday["date"]}!</li>\n"
    end

    response.write "</ul>\n"
    response.write <<~SRT
      <form action="/add/birthday" method="post" enctype="application/x-www-form-urlencoded">
        <p><label>Name <input type="text" name="name"></label></p>
        <p><label>Birthday <input type="date" name="date"></label></p>
        <p><button>Submit birthday</button></p>
      </form>
    SRT
    response.write "</body>\n"
  elsif request.post? && request.path == "/add/birthday"
    new_birthday = request.params

    # Create a query for New User-Inputted row
    query = "INSERT INTO birthdays (name, date) VALUES (?, ?)"
    database.execute(query, [new_birthday['name'], new_birthday['date']])

    response.redirect('/show/birthdays', 303)
  else
    response.content_type = "text/plain; charset=UTF-8"
    response.write("Received a #{request.request_method} request to #{request.path}")
  end

  response.finish
}

Rack::Handler::Puma.run(app, :Port => 1337, :Verbose => true)
