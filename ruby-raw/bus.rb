#!/usr/bin/env ruby
require 'nn-core'
require_relative 'assert'

NN = NNCore::LibNanomsg # shortcut

def node(argv)
  name = argv[0]
  name_null = "#{name}\0"
  assert sock = NN.nn_socket(NNCore::AF_SP, NNCore::NN_BUS)
  assert NN.nn_bind(sock, argv[1])

  option = FFI::MemoryPointer.new(:int32)
  option.write_int(100)
  assert NN.nn_setsockopt(sock, NNCore::NN_SOL_SOCKET, NNCore::NN_RCVTIMEO, option, 4)
  option.free

  sleep (1) # wait for connections
  argv[2..-1].each do |url|
    assert NN.nn_connect(sock, url)
  end
  sleep (1) # wait for connections

  # SEND
  puts "#{name}: SENDING '#{name}' ONTO BUS"
  assert NN.nn_send(sock, name_null, name_null.size, 0) == name_null.size

  buf = FFI::MemoryPointer.new(:pointer, 1)
  loop do
    recv = NN.nn_recv(sock, buf, NNCore::NN_MSG, 0);
    if (recv >= 0)
      puts "#{name}: RECEIVED '#{buf.get_pointer(0).get_string(0, recv)}' FROM BUS"
      NN.nn_freemsg(buf.get_pointer(0));
    end
  end
  buf.free
  NN.nn_shutdown(sock, 0)
end

if ARGV.length >= 3
  node(ARGV)
else
  $stderr.puts "Usage: #{$PROG_NAME} <NODE_NAME> <URL> <URL> ..."
  exit 1
end
