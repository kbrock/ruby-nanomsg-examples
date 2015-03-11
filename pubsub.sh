
# based upon the c examples found at https://github.com/dysinger/nanomsg-examples

./ruby/pubsub.rb server ipc:///tmp/pubsub.ipc & server=$! && sleep 1
./ruby/pubsub.rb client ipc:///tmp/pubsub.ipc client0 & client0=$!
./ruby/pubsub.rb client ipc:///tmp/pubsub.ipc client1 & client1=$!
./ruby/pubsub.rb client ipc:///tmp/pubsub.ipc client2 & client2=$!
sleep 5
kill $server $client0 $client1 $client2
