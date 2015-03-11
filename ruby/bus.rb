#!/usr/bin/env ruby

# based upon the c examples found at https://github.com/dysinger/nanomsg-examples

require_relative 'node'

class Node0 < Node
  def run(name, url, other_urls)
    name_null = "#{name}\0"
    with_socket(NNCore::AF_SP, NNCore::NN_BUS, url, NNCore::NN_RCVTIMEO => 100) do |sock, buf|
      sleep (1) # wait for connections
      other_urls.each do |o_url|
        assert NN.nn_connect(sock, o_url)
      end
      sleep (1) # wait for connections

      # SEND
      puts "#{name}: SENDING '#{name}' ONTO BUS"
      send_string(sock, name_null)

      loop do
        with_recv_string(sock, buf, false) do |str|
          puts "#{name}: RECEIVED '#{str}' FROM BUS"
        end
      end
    end
  end
end

if ARGV.length >= 3
  Node0.new.run(ARGV[0], ARGV[1], ARGV[2..-1])
else
  $stderr.puts "Usage: #{$PROG_NAME} <NODE_NAME> <URL> <URL> ..."
  exit 1
end
