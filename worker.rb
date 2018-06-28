require 'socket'
require './message'
require './sort'

class Worker
  def initialize(server)
    @server = server
    @response = nil
    listen
    join
    @response.join
  end

  private

  def listen
    @response = Thread.new do
      loop {
        string_message = @server.gets.chomp
        message = Message.read(string_message)

        array_sorted = Sort.bubble_sort(message[:array])
        worker_id = message[:worker_id]

        @server.puts Message.send(worker_id, array_sorted)
      }
    end
  end

  def join
    puts "Enter your worker ID:"
    id = $stdin.gets.chomp

    @server.puts(id)
  end
end

server = TCPSocket.open('localhost', 3000)
Worker.new(server)
