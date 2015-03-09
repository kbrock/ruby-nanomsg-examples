# ruby nanomsg examples

Here are a number of examples for exercising the various messaging paradigms found in [nanomsg][]. They are a ruby version of those found in [nanomsg-examples][].

A procedural version can be found in [ruby-raw](./ruby_raw) which strive to be as close to the c version as possible.

A more object oriented version can be found in [ruby](./ruby/).

There are a number of assumptions that could be applied to further simplify these examples. One example being there is only 1 url, 1 socket, 1 message buffer, and only 1 message active at a time. I believe these to all be valid.

Instead here I opted to develop more as helper functions with no class variables. I hope this can be used as a base for your entertainment and coding endevours.

# Goals

- Better understand FFI and nanomsg
- Equivalent scripts and usages as [nanomsg-examples][]
- Equivalent wire protocol as nanomsg-example. (mix and match)
- no instance variables

# Thanks

Thanks to the great c examples from [nanomsg-examples][] and the example and library from [nn-core][].

[nanomsg]: http://nanomsg.github.io/nanomsg/index.html
[nanomsg-examples]: http://github.com/dysinger/nanomsg-examples/
[nn-core]: http://github.com/chuckremes/nn-core
