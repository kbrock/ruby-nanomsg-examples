
# based upon the c examples found at https://github.com/dysinger/nanomsg-examples

./ruby/pipeline.rb node0 ipc:///tmp/pipeline.ipc & node0=$! && sleep 1
./ruby/pipeline.rb node1 ipc:///tmp/pipeline.ipc "Hello, World!"
./ruby/pipeline.rb node1 ipc:///tmp/pipeline.ipc "Goodbye."
kill $node0

