
# based upon the c examples found at https://github.com/dysinger/nanomsg-examples

./ruby/pair.rb node0 ipc:///tmp/pair.ipc & node0=$!
./ruby/pair.rb node1 ipc:///tmp/pair.ipc & node1=$!
sleep 3
kill $node0 $node1
