require 'socket'

server = TCPServer.new(1337)

# Accept incomming Connections
loop do
  client = server.accept

# Get the Input from Client Side
  client.puts "What's your name?"
  input = client.gets
  puts "Received #{input.chomp} from a client socket on 1337"
  client.puts "Hi, #{input.chomp}! You've successfully connected to the server socket."

# Closing the Client Socket
  puts "Closing client socket"
  client.puts "Goodbye #{input}"
  client.close
end
