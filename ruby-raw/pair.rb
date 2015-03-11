#!/usr/bin/env ruby

# based upon the c examples found at https://github.com/dysinger/nanomsg-examples

require 'nn-core'
require_relative 'assert'

NODE0 = "node0"
NODE1 = "node1"

NN = NNCore::LibNanomsg # shortcut

def send_name(sock, name)
  name_null = "#{name}\0"
  puts ("#{name}: SENDING \"#{name}\"\n");
  NN.nn_send(sock, name_null, name_null.size, 0);
end

def recv_name(buf, sock, name)
  recv = NN.nn_recv(sock, buf, NNCore::NN_MSG, 0)
  if (recv > 0)
    puts "#{name}: RECEIVED \"#{buf.get_pointer(0).get_string(0, recv)}\""
    NN.nn_freemsg(buf.get_pointer(0));
  end
  recv
end

def send_recv(sock, name)
  option = FFI::MemoryPointer.new(:int32)
  option.write_int(100)
  assert NN.nn_setsockopt(sock, NNCore::NN_SOL_SOCKET, NNCore::NN_RCVTIMEO, option, 4)
  option.free

  buf = FFI::MemoryPointer.new(:pointer, 1)
  loop do
    recv_name(buf, sock, name)
    sleep(1)
    send_name(sock, name)
  end
  buf.free
end

def node0(url)
  assert sock = NN.nn_socket(NNCore::AF_SP, NNCore::NN_PAIR)
  assert NN.nn_bind(sock, url)
  send_recv(sock, NODE0);
  NN.nn_shutdown(sock, 0);
end

def node1(url)
  assert sock = NN.nn_socket(NNCore::AF_SP, NNCore::NN_PAIR)
  assert NN.nn_connect(sock, url)
  send_recv(sock, NODE1);
  NN.nn_shutdown(sock, 0);
end

if ARGV.length >= 2 && ARGV[0] == NODE0
  node0(ARGV[1])
elsif ARGV.length >= 2 && ARGV[0] == NODE1
  node1(ARGV[1])
else
  $stderr.puts "Usage: #{$PROG_NAME} #{NODE0}|#{NOTE1} <URL> <ARG> ..."
end
