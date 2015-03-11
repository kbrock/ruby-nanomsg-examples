
# based upon the c examples found at https://github.com/dysinger/nanomsg-examples

./ruby/survey.rb server ipc:///tmp/survey.ipc & server=$!
./ruby/survey.rb client ipc:///tmp/survey.ipc client0 & client0=$!
./ruby/survey.rb client ipc:///tmp/survey.ipc client1 & client1=$!
./ruby/survey.rb client ipc:///tmp/survey.ipc client2 & client2=$!
sleep 3
kill $server $client0 $client1 $client2

