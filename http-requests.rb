require 'socket'

server = TCPServer.new(1337)

# Accept incomming Connections
loop do
  client = server.accept

# Get the Request-line of the Request
  request_line = client.readline

  puts "The HTTP request line looks like this:"
  puts request_line

# Breaks down the THHP request form the client
  method_token, target, version_number = request_line.split
  response_body = "v/ Received a #{method_token} request to #{target} with #{version_number}"

  client.puts response_body
  client.close
end
