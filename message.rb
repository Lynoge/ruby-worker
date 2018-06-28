class Message
  class << self
    def send(worker_id, array)
      array_unpacked = array.join('|')

      "worker_id: #{worker_id}, array: #{array_unpacked}"
    end

    def read(message)
      splitted_message = message.split(',')

      worker_id = splitted_message.first.delete('worker_id: ')
      array = splitted_message.last.delete('array: ')

      {
        worker_id: worker_id,
        array: array.split('|').map(&:to_i)
      }
    end
  end
end
