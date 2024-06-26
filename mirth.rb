require 'socket'

server = TCPServer.new(1337)

# Default data that are not persistent
birthdays = [
  { name: 'Gma', date: '01/01/2021' },
  { name: 'Tom', date: '02/01/2021' },
  { name: 'Sesame', date: '03/01/2021' },
]

# Accept incomming Connections
loop do
  client = server.accept

# Get the Request-line of the Request
  request_line = client.readline

  puts "The HTTP request line looks like this:"
  puts request_line

# Breaks down the THHP request form the client
  method_token, target, version_number = request_line.split
  
# Create a Case Statement to handle all the endpoints
  case [method_token, target]
  when ["GET", "/show/birthdays"]
    # Endpoint for GET /show/birthdays
    reponse_status_code = "200 OK"
    content_type = "text/html"
    response_message = ""

    response_message << "<ul>\n"
    birthdays.each do |birthday|
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
  when ["POST", "/add/birthday"]
    # Endpoint for POST /add/birthday
    response_status_code = "303 See Other"
    content_type = "text/html"
    response_message = ""

    # Break apart header fields to get the
    # Content-Length which will help us get the body
    # of the message
    all_headers = {}
    while true
      line = client.readline
      break if line == "\r\n"
      header_name, value = line.split(": ")
      all_headers[header_name] = value
    end
    body = client.read(all_headers['Content-Length'].to_i)

    # Use Ruby's build in decoder library
    # to decode the body into a Hash object
    require 'uri'
    new_birthday = URI.decode_www_form(body).to_h

    birthdays << new_birthday.transform_keys(&:to_sym)

  else
    response_status_code = "200 OK"
    response_message = "Received a #{method_token} request to #{target} with #{version_number}"
    content_type = "text/plain"
  end

  puts response_message
  # Construct the HTTP Response
  http_response = <<~MSG
      #{version_number} #{response_status_code}
      Content-Type: #{content_type}; charset=#{response_message.encoding.name}
      Location: /show/birthdays

      #{response_message}
  MSG

  client.puts http_response
  client.close
end
