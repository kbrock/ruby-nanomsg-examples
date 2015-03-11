#!/usr/bin/env ruby

# based upon the c examples found at https://github.com/dysinger/nanomsg-examples

require 'nn-core'
require_relative 'assert'

NODE0 = "node0"
NODE1 = "node1"

NN = NNCore::LibNanomsg # shortcut

def node0(url)
  assert sock = NN.nn_socket(NNCore::AF_SP, NNCore::NN_PULL)
  assert NN.nn_bind(sock, url)
  buf = FFI::MemoryPointer.new(:pointer, 1)
  loop do
    assert bytes = NN.nn_recv(sock, buf, NNCore::NN_MSG, 0)
    str = buf.read_pointer.get_string(0, bytes)
    puts "NODE0: RECEIVED \"#{str}\""
    NN.nn_freemsg(buf.read_pointer)
  end
  buf.free
end

def node1 (url, msg)
  msg_null = "#{msg}\0"
  assert sock = NN.nn_socket(NNCore::AF_SP, NNCore::NN_PUSH)
  assert NN.nn_connect(sock, url)
  puts "NODE1: SENDING \"#{msg}\""
  assert NN.nn_send(sock, msg_null, msg_null.size, 0) == msg_null.size
  NN.nn_shutdown(sock, 0)
end

if ARGV.length >= 2 && ARGV[0] == NODE0
  node0 ARGV[1]
elsif ARGV.length >= 3 && ARGV[0] == NODE1
  node1 ARGV[1], ARGV[2]
else
  $stderr.puts "Usage: pipeline #{NODE0}|#{NODE1} <URL> <ARG> ..."
  exit 1
end

