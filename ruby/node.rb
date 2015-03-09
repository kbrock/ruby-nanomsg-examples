require 'nn-core'

class Node
  NN = NNCore::LibNanomsg # shortcut
  SERVER_PROTOCOLS = [NNCore::NN_REP, NNCore::NN_BUS,
                      NNCore::NN_PULL, NNCore::NN_PUB]

  def with_socket(domain, protocol, url, options = {})
    assert sock = NN.nn_socket(domain, protocol)
    # receiving nodes bind, sending nodes connect
    mode = if (options.delete(:bind) || SERVER_PROTOCOLS.include?(protocol))
      :nn_bind
    else
      :nn_connect
    end
    assert NN.send(mode, sock, url)

    socket_options(sock, options)
    # assuming that we want a buffer to receive data over this socket
    with_buffer { |buf| yield sock, buf }
    NN.nn_shutdown(sock, 0)
  end

  def socket_options(sock, options)
    return if options.empty?
    int_option = FFI::MemoryPointer.new(:int32)
    options.each do |name, value|
      if value.is_a?(Numeric)
        int_option.write_int(value)
        assert NN.nn_setsockopt(sock, NNCore::NN_SOL_SOCKET, name, option, 4)
      elsif value.is_a?(String) && name == NNCore::NN_SUB_SUBSCRIBE
        option = FFI::MemoryPointer.from_string(value)
        assert NN.nn_setsockopt(sock, NNCore::NN_SUB, name, option, 0)
        option.free
      else
        raise IllegalArgument, "Don't know how to set socket option for #{name}:#{value}"
      end
    end
    int_option.free
  end

  def with_buffer
    yield buf = FFI::MemoryPointer.new(:pointer, 1)
  ensure
    buf.free
  end

  def with_recv_string(sock, buf, fail_if_empty_msg = true)
    # some code wants an assert >=0 here
    bytes = NN.nn_recv(sock, buf, NNCore::NN_MSG, 0)
    assert(bytes >= 0) if fail_if_empty_msg
    if bytes >= 0
      yield buf.read_pointer.get_string(0, bytes)
      NN.nn_freemsg(buf.read_pointer)
    end
  end

  def send_string(sock, d, add_nil = false)
    d = "#{d}\0" if add_nil
    assert NN.nn_send(sock, d, d.size, 0) == d.size
  end

  def assert(rc)
    if (rc == false) || (rc != true && rc < 0)
      raise "Last API call failed at #{caller(1)}"
    end
    rc
  end
end
