require 'socket'
require './message'

class Worker
  def initialize(server)
    @server = server
    @request = nil
    @response = nil
    listen
    send
    @request.join
    @response.join
  end

  def listen
    @response = Thread.new do
      loop {
        string_message = @server.gets.chomp
        puts Message.read(string_message)
      }
    end
  end

  def send
    puts "Enter your worker ID:"
    id = $stdin.gets.chomp

    join(id)

    @request = Thread.new do
    end
  end

  private

  def join(id)
    @server.puts(id)
  end
end

server = TCPSocket.open('localhost', 3000)
Worker.new(server)
