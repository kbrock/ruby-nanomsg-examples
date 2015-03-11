#!/usr/bin/env ruby

# based upon the c examples found at https://github.com/dysinger/nanomsg-examples

require 'nn-core'
require 'time'
require_relative 'assert'

SERVER = "server"
CLIENT = "client"

NN = NNCore::LibNanomsg # shortcut

def date
  Time.now.strftime "%a %b %e %H:%M:%S %Y\0"
end

def server(url)
  assert sock = NN.nn_socket(NNCore::AF_SP, NNCore::NN_PUB)
  assert NN.nn_bind(sock, url)
  loop do
    d = date
    puts "SERVER: PUBLISHING DATE #{d}"
    assert NN.nn_send(sock, d, d.size, 0) == d.size
    sleep(1)
  end
  # never reached
  NN.nn_shutdown(sock, 0)
end

def client(url, name)
  buf = FFI::MemoryPointer.new(:pointer, 1)

  assert sock = NN.nn_socket(NNCore::AF_SP, NNCore::NN_SUB)
  # TODO learn more about publishing/subscribe keys
  option = FFI::MemoryPointer.from_string("")
  assert NN.nn_setsockopt(sock, NNCore::NN_SUB, NNCore::NN_SUB_SUBSCRIBE, option, 0)
  assert NN.nn_connect(sock, url)
  option.free

  loop do
    assert bytes = NN.nn_recv(sock, buf, NNCore::NN_MSG, 0)
    str = buf.read_pointer.get_string(0, bytes)
    puts "CLIENT (#{name}): RECEIVED #{str}"
    NN.nn_freemsg(buf.read_pointer)
  end
  buf.free
  NN.nn_shutdown(sock, 0);
end

if ARGV.length >= 2 && ARGV[0] == SERVER
  server ARGV[1]
elsif ARGV.length >= 3 && ARGV[0] == CLIENT
  client ARGV[1], ARGV[2]
else
  $stderr.puts "Usage: #{$PROG_NAME} #{SERVER}|#{CLIENT} <URL> <ARG> ..."
end
