module Vico
  # TODO use comms module...
  module Comms
    def self.send(message, socket:)
      payload = encode message
      socket.puts(payload)
    end

    def self.read(socket:)
      if (data = socket.gets.chomp)
        decode data
      end
    end

    def self.encode(msg) # => bytes
      # $stdout.puts("ENCODE MESSAGE #{msg}")
      JSON.dump(msg)
    end

    def self.decode(bytes) # => msg
      JSON.parse(bytes, symbolize_names: true)
    end
  end
end
