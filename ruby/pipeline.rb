#!/usr/bin/env ruby

# based upon the c examples found at https://github.com/dysinger/nanomsg-examples

require_relative 'node'

class Node0 < Node
  def run(url)
    with_socket(NNCore::AF_SP, NNCore::NN_PULL, url) do |sock, buf|
      loop do
        with_recv_string(sock, buf) do |str|
          puts "NODE0: RECEIVED \"#{str}\""
        end
      end
      # never reached
    end
  end
end

class Node1 < Node
  def run(url, msg)
    with_socket(NNCore::AF_SP, NNCore::NN_PUSH, url) do |sock, buf|
      puts "NODE1: SENDING \"#{msg}\""
      send_string(sock, msg, true)
    end
  end
end

if ARGV.length >= 2 && ARGV[0] == "node0"
  Node0.new.run ARGV[1]
elsif ARGV.length >= 3 && ARGV[0] == "node1"
  Node1.new.run ARGV[1], ARGV[2]
else
  $stderr.puts "Usage: pipeline node0|node1 <URL> <ARG> ..."
  exit 1
end

