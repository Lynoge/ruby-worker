class Message
  class << self
    def send(worker_id, array)
      array_unpacked = array.join('|')

      "worker_id: #{worker_id}, array: #{array_unpacked}"
    end

    def read(message)
      splitted_message = message.split(',')

      worker_id = splitted_message.first.delete('worker_id: ')
      x = splitted_message.last.delete('array: ')

      {
        worker_id: worker_id,
        array: x.split('|').map(&:to_i).sort,
      }
    end
  end
end
