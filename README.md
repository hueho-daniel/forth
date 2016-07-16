# Forth in Elixir

Small Forth interpreter in Elixir using Erlang parsing tools, made to scratch an itch. It's small, inefficient, impratical, broken if you poke on it too hard, but cute enough (to me) to dump in Github. Also works as a small introduction to how to use `yecc` and `leex` in Mix projects.

The project itself is based of [this exercism.io exercise](http://exercism.io/exercises/elixir/forth), but with blocks (AKA anonymous functions), using some syntax stolen from [Factor quotations](http://docs.factorcode.org/content/article-quotations.html). It models the stack as a simple list and the word dictionary as a map.

## TODO

- Add more basic datatypes (strings, atoms, floats)
  - Strings and floats are parsed and pushed to the stack, but there is no library support
  - Strings can't be escaped
- Add native call support (to call external Erlang/Elixir libs)
- Clean up code

## License

The `test/forth_text.exs` file was based of the original test suite from exercism.io, and as such is licensed under the AGPL version 3.0.
Everything else is under the MIT license.
