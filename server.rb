require 'socket'
require './message'

class Server
  def initialize(port, ip)
    @server = TCPServer.open(ip, port)
    @shuffle_matrix = (0..9).map { (1..10000).to_a.shuffle }
    @sorted_matrix = []
    @workers = []
    run
  end

  def run
    loop {
      Thread.start(@server.accept) do | socket |
        username = socket.gets.chomp.to_sym
        register_client(username, socket)
        # listen_client_messages(username, socket)
      end
    }.join
  end

  def listen_client_messages(username, socket)
    loop {
      string_message = socket.gets.chomp
      message = Message.new(string_message)
    }
  end

  private

  def register_client(id, socket)
    puts "#{id} #{socket}"
    @workers << {
      id: id,
      socket: socket,
      is_free: true
    }
    send_job
  end

  def send_job
    @workers.first[:socket].puts Message.send(@workers.first[:id], @shuffle_matrix.first)
  end
end

Server.new(3000, 'localhost')
