#!/usr/bin/env ruby

# based upon the c examples found at https://github.com/dysinger/nanomsg-examples

require 'nn-core'
require 'time'
require_relative 'assert'

NODE0 = "node0"
NODE1 = "node1"
DATE  = "DATE\0"

NN = NNCore::LibNanomsg # shortcut

def date
  Time.now.strftime "%a %b %e %H:%M:%S %Y\0"
end

def node0(url)
  assert sock = NN.nn_socket(NNCore::AF_SP, NNCore::NN_REP)
  assert NN.nn_bind(sock, url)
  buf = FFI::MemoryPointer.new(:pointer, 1)
  loop do
    assert bytes = NN.nn_recv(sock, buf, NNCore::NN_MSG, 0)
    str = buf.read_pointer.get_string(0, bytes)

    if str == DATE[0..-2] # ignoring null terminator
      puts "NODE0: RECEIVED DATE REQUEST"
      d = date
      puts "NODE0: SENDING DATE #{d}"
      assert NN.nn_send(sock, d, d.size, 0) == d.size
    end
    NN.nn_freemsg(buf.read_pointer)
  end
  # never reached
  buf.free
  NN.nn_shutdown(sock, 0)
end

def node1(url)
  buf = FFI::MemoryPointer.new(:pointer, 1)

  assert sock = NN.nn_socket(NNCore::AF_SP, NNCore::NN_REQ)
  assert NN.nn_connect(sock, url)
  puts "NODE1: SENDING DATE REQUEST \"#{DATE}\""
  assert NN.nn_send(sock, DATE, DATE.size, 0) == DATE.size
  assert bytes = NN.nn_recv(sock, buf, NNCore::NN_MSG, 0)
  # read_string would probably work since it is null terminated
  puts "NODE1: RECEIVED DATE #{buf.read_pointer.get_string(0, bytes)}"
  NN.nn_freemsg(buf.read_pointer)
  buf.free
  NN.nn_shutdown(sock, 0)
end

if ARGV.length >= 2 && ARGV[0] == NODE0
  node0 ARGV[1]
elsif ARGV.length >= 2 && ARGV[0] == NODE1
  node1 ARGV[1]
else
  $stderr.puts "Usage: #{$PROG_NAME} #{NODE0}|#{NOTE1} <URL> <ARG>"
end
