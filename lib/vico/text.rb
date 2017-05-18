module Vico
  # first client!!
  # TODO need to handle redirection....
  #      also can't just be a subclass of client :/
  class Text # < Client
    attr_reader :listen_thread

    def initialize(host: 'localhost', port: 7060)
      puts "---> Text would connect to local world server..."
      @visited = [{host: host, port: port}]
      $client = Vico::Client.new(host: host, port: port)
      @listen_thread = connect_client!
      # super
    end

    def connect_client!
      $client.connect!
      $client.poll(&method(:listen))
      $client.command('iam joe')
      $client.command('look')
    end

    def listen(event)
      $stdout.puts event[:description]
      if event[:host] && event[:port]
        $stdout.puts "(FOLLOW REDIRECT TO #{event[:host]}:#{event[:port]})"
        host, port = event[:host], event[:port] #.fetch_all(:host, :port)
        $stdout.puts "REDIRECT CLIENT TO #{host}:#{port}"
        @visited.push({host: host, port: port})
        $client = Vico::Client.new(host: host, port: port)
        #event[:host], port: event[:port])
        connect_client!
      end
    end

    def prompt; "vico> " end

    def engage!
      rep! while !$client.quit?
    rescue => ex
      $stdout.puts ex.message
      $stdout.puts ex.backtrace
    end

    def rep!
      sleep 0.05
      puts
      msg = Readline.readline(prompt, true)
      if msg
        cmd = msg.chomp
        if cmd == 'quit' or cmd == 'exit'
          $client.command('drop')
          $client.quit!
        elsif cmd == 'out' # try to leave current space...
          $client.command 'drop'
          @visited.pop
          last_server = @visited.last
          $stdout.puts "---> Dropping back to last server: #{last_server}"
          $client = Vico::Client.new(host: last_server[:host], port: last_server[:port]) #host: last_server[:host, port: port)
          connect_client!
        else
          $client.command(cmd)
        end
      end
    end
  end
end
