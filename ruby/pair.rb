#!/usr/bin/env ruby

# based upon the c examples found at https://github.com/dysinger/nanomsg-examples

require_relative 'node'

class Node0 < Node
  def run(name, url, bind)
    name_null = "#{name}\0"
    with_socket(NNCore::AF_SP, NNCore::NN_PAIR, url,
                :bind               => bind,
                NNCore::NN_RCVTIMEO => 100,
                ) do |sock, buf|
      loop do
        with_recv_string(sock, buf, false) do |str|
          puts "#{name}: RECEIVED \"#{str}\"" if str
        end
        sleep(1)
        puts ("#{name}: SENDING \"#{name}\"\n");
        send_string(sock, name_null)
      end
    end
  end
end

if ARGV.length >= 2 && ARGV[0] == "node0"
  Node0.new.run(ARGV[0], ARGV[1], true)
elsif ARGV.length >= 2 && ARGV[0] == "node1"
  Node0.new.run(ARGV[0], ARGV[1], false)
else
  $stderr.puts "Usage: #{$PROG_NAME} #{NODE0}|#{NOTE1} <URL> <ARG> ..."
end
