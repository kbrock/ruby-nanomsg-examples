#!/usr/bin/env ruby
require 'nn-core'
require 'time'
require_relative 'node'

class Server < Node
  DATE  = "DATE\0"

  def run(url)
    with_socket(NNCore::AF_SP, NNCore::NN_SURVEYOR, url) do |sock, buf|
      sleep 1
      puts "SERVER: SENDING DATE SURVEY REQUEST"
      send_string(sock, DATE)
      loop do
        with_recv_string(sock, buf, false) do |str|
          break if str.nil?
          puts "SERVER: RECEIVED \"#{str}\" SURVEY RESPONSE"
        end
      end
    end
  end
end

class Client < Node
  def run(url, name)
    with_socket(NNCore::AF_SP, NNCore::NN_RESPONDENT, url) do |sock, buf|
      loop do
        with_recv_string(sock, buf, 0) do |str|
          puts "CLIENT (#{name}): RECEIVED \"#{str}\" SURVEY REQUEST"
          d = date
          puts "CLIENT (#{name}): SENDING DATE SURVEY RESPONSE"
          send_string(sock, d)
        end
      end
    end
  end

  private

  def date
    Time.now.strftime "%a %b %e %H:%M:%S %Y\0"
  end  
end

if ARGV.length >= 2 && ARGV[0] == "server"
  Server.new.run ARGV[1]
elsif ARGV.length >= 3 && ARGV[0] == "client"
  Client.new.run ARGV[1], ARGV[2]
else
  $stderr.puts "Usage: #{$PROG_NAME} server|client <URL> <ARG> ..."
end

