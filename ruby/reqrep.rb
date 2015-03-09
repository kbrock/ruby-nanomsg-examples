#!/usr/bin/env ruby
require 'nn-core'
require_relative 'node'
require 'time'

class Node0 < Node
  DATE  = "DATE\0"

  def run(url)
    with_socket(NNCore::AF_SP, NNCore::NN_REP, url) do |sock, buf|
      loop do
        with_recv_string(sock, buf) do |str|
          if str == DATE[0..-2] # ignoring null terminator
            puts "NODE0: RECEIVED DATE REQUEST"
            d = date
            puts "NODE0: SENDING DATE #{d}"
            send_string(sock, d)
          end
        end
      end
      # never reached
    end
  end

  private

  def date
    Time.now.strftime "%a %b %e %H:%M:%S %Y\0"
  end  
end

class Node1 < Node
  DATE  = "DATE\0"

  def run(url)
    with_socket(NNCore::AF_SP, NNCore::NN_REQ, url) do |sock, buf|
      puts "NODE1: SENDING DATE REQUEST \"#{DATE}\""
      send_string(sock, DATE)
      with_recv_string(sock, buf) do |str|
        puts "NODE1: RECEIVED DATE #{str}"
      end
    end
  end
end

if ARGV[1] && ARGV[0] == "node0"
  Node0.new.run(ARGV[1])
elsif ARGV[1] && ARGV[0] == "node1"
  Node1.new.run(ARGV[1])
else
  $stderr.puts "Usage: #{$PROG_NAME} #{NODE0}|#{NOTE1} <URL> <ARG>"
end
