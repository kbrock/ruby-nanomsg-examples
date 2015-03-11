#!/usr/bin/env ruby

# based upon the c examples found at https://github.com/dysinger/nanomsg-examples

require 'nn-core'
require 'time'
require_relative 'assert'

SERVER = "server"
CLIENT = "client"
DATE   = "DATE\0"

NN = NNCore::LibNanomsg # shortcut

def date
  Time.now.strftime "%a %b %e %H:%M:%S %Y\0"
end

def server(url)
  assert sock = NN.nn_socket(NNCore::AF_SP, NNCore::NN_SURVEYOR)
  assert NN.nn_bind(sock, url)
  buf = FFI::MemoryPointer.new(:pointer, 1)
  sleep(1) # wait for connections
  puts "SERVER: SENDING DATE SURVEY REQUEST"
  assert NN.nn_send(sock, DATE, DATE.size, 0) == DATE.size
  loop do
    bytes = NN.nn_recv(sock, buf, NNCore::NN_MSG, 0)
    break if (bytes == NNCore::ETIMEDOUT)
    if (bytes >= 0)
      puts "SERVER: RECEIVED \"#{buf.get_pointer(0).get_string(0, bytes)}\" SURVEY RESPONSE"
      NN.nn_freemsg(buf.get_pointer(0))
    end
  end
  buf.free
  NN.nn_shutdown(sock, 0)
end

def client(url, name)
  assert sock = NN.nn_socket(NNCore::AF_SP, NNCore::NN_RESPONDENT)
  assert NN.nn_connect(sock, url)
  buf = FFI::MemoryPointer.new(:pointer, 1)
  loop do
    bytes = NN.nn_recv(sock, buf, NNCore::NN_MSG, 0)
    if (bytes >= 0)
      puts "CLIENT (#{name}): RECEIVED \"#{buf.get_pointer(0).get_string(0, bytes)}\" SURVEY REQUEST"
      NN.nn_freemsg (buf.get_pointer(0))
      d = date
      puts "CLIENT (#{name}): SENDING DATE SURVEY RESPONSE"
      assert NN.nn_send(sock, d, d.size, 0) == d.size
    end
  end
  buf.free
  NN.nn_shutdown(sock, 0)
end

if ARGV.length >= 2 && ARGV[0] == SERVER
  server ARGV[1]
elsif ARGV.length >= 3 && ARGV[0] == CLIENT
  client ARGV[1], ARGV[2]
else
  $stderr.puts "Usage: #{$PROG_NAME} #{SERVER}|#{CLIENT} <URL> <ARG> ..."
end

