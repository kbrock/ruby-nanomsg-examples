#!/usr/bin/env ruby
require 'nn-core'
require 'time'
require_relative 'node'

SERVER = "server"
CLIENT = "client"

class Server < Node
  def run(url)
    with_socket(NNCore::AF_SP, NNCore::NN_PUB, url) do |sock, buf|
      loop do
        d = date
        puts "SERVER: PUBLISHING DATE #{d}"
        assert send_string(sock, d)
        sleep(1)
      end
    end
    # never reached
    NN.nn_shutdown(sock, 0)
  end

  private

  def date
    Time.now.strftime "%a %b %e %H:%M:%S %Y\0"
  end
end

class Client < Node
  def run(url, name)
    # TODO learn more about publishing/subscribe keys
    with_socket(NNCore::AF_SP, NNCore::NN_SUB, url,
                NNCore::NN_SUB_SUBSCRIBE => "") do |sock, buf|
      loop do
        with_recv_string(sock, buf) do |str|
          puts "CLIENT (#{name}): RECEIVED #{str}"
        end
      end
    end
  end
end

if ARGV.length >= 2 && ARGV[0] == "server"
  Server.new.run ARGV[1]
elsif ARGV.length >= 3 && ARGV[0] == "client"
  Client.new.run ARGV[1], ARGV[2]
else
  $stderr.puts "Usage: #{$PROG_NAME} server|client <URL> <ARG> ..."
end
