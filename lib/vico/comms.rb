module Vico
  # TODO use comms module...
  module Comms
    def self.send(message, socket:)
      payload = encode message
      socket.puts(payload)
    end

    def self.read(socket:)
      if (raw_line = socket.gets) #.chomp)
        data = raw_line.chomp
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

    def self.test!(socket:)
      begin
        send({ping: true}, socket: socket)
        # if read(socket: socket).has_key?(:ping)
        # socket.puts('')
        true
      rescue
        false
      end
    end
  end
end
