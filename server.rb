require 'socket'
require './message'

class Server
  def initialize(port, ip)
    @server = TCPServer.open(ip, port)
    @shuffle_matrix = (0..9).map { (1..10000).to_a.shuffle }
    @sorted_matrix = []
    @workers = []
    show
    run
  end

  def show
    Thread.new {
      loop do
        show_lists
      end
    }
  end

  def run
    loop {
      Thread.start(@server.accept) do | socket |
        username = socket.gets.chomp.to_sym
        register_client(username, socket)
        listen_client_messages(username, socket)
      end

      Thread.start {
        loop do
          send_unsorted_list
        end
      }
    }.join
  end

  private

  def listen_client_messages(username, socket)
    loop {
      string_message = socket.gets.chomp
      message = Message.read(string_message)

      worker = find_worker_by(message[:worker_id])
      worker[:is_free] = true
      @sorted_matrix << message[:array]
    }
  end

  def send_unsorted_list
    worker = find_free_worker
    send_list_to(worker) if worker && @shuffle_matrix.length > 0
  end

  def register_client(id, socket)
    @workers << {
      id: id,
      socket: socket,
      is_free: true
    }
  end

  def find_free_worker
    @workers.find { |worker| worker[:is_free] }
  end

  def find_worker_by(id)
    @workers.find { |worker| worker[:id] === id.to_sym }
  end

  def send_list_to(worker)
    worker[:is_free] = false
    worker[:socket].puts Message.send(worker[:id], @shuffle_matrix.pop)
  end

  def show_lists
    unsorted_matrix = @shuffle_matrix.map { |curr_list| "#{curr_list.first(3).join(', ')}...#{curr_list.last(3).join(', ')}" }
    puts "--- Unsorted lists ---"
    puts unsorted_matrix

    sorted_matrix = @sorted_matrix.map { |curr_list| "#{curr_list.first(3).join(', ')}...#{curr_list.last(3).join(', ')}" }
    puts "--- Sorted lists ---"
    puts sorted_matrix

    puts "--- Workers ---"
    puts @workers
    sleep(3)
  end
end

Server.new(3000, 'localhost')
