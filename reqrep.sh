
# based upon the c examples found at https://github.com/dysinger/nanomsg-examples

./ruby/reqrep.rb node0 ipc:///tmp/reqrep.ipc & node0=$! && sleep 1
./ruby/reqrep.rb node1 ipc:///tmp/reqrep.ipc
kill $node0
