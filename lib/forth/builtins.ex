defmodule Forth.Builtins do
  alias Forth.Exceptions

  defmodule Internals do
    def block_eval(block_tuple, stack, closure \\ %{})

    def block_eval([], stack, _),
      do: stack
    def block_eval([{:capture, capture_list}|rest], stack, closure) do
      {next_stack, next_closure} = create_closure(capture_list, stack, closure)
      block_eval(rest, next_stack, next_closure)
    end
    def block_eval([{:closure, name}|rest], stack, closure),
      do: block_eval(rest, [closure[name]|stack], closure)
    def block_eval([{:def, fun}|rest], stack, closure) when is_function(fun),
      do: block_eval(rest, fun.(stack, closure), closure)
    def block_eval([{:def, body}|rest], stack, closure) do
      next_stack = block_eval(body, stack, %{})
      block_eval(rest, next_stack, closure)
    end
    def block_eval([term|rest], stack, closure),
      do: block_eval(rest, [term|stack], closure)
    def block_eval({:compiled, block}, stack, closure),
      do: block_eval(block, stack, closure)

    def create_closure([], stack, closure), do: {stack, closure}
    def create_closure([name|rest], [value|stack], closure),
      do: create_closure(rest, stack, Map.put(closure, name, value))
    def create_closure([_|_], [], _),
      do: raise Exceptions.StackUnderflow, []
  end

  defmodule Arithmetic do
    def sum([b, a | rest], _), do: [a + b | rest]
    def sum(stack, _), do: raise Exceptions.StackUnderflow, stack

    def sub([b, a | rest], _), do: [a - b | rest]
    def sub(stack, _), do: raise Exceptions.StackUnderflow, stack

    def mul([b, a | rest], _), do: [a * b | rest]
    def mul(stack, _), do: raise Exceptions.StackUnderflow, stack

    def div([0, _ | _any], _), do: raise Exceptions.DivisionByZero
    def div([b, a | rest], _), do: [:erlang.div(a, b) | rest]
    def div(stack, _), do: raise Exceptions.StackUnderflow, stack

    def eq([b, a | rest], _), do: [to_int(a == b) | rest]
    def eq(stack, _), do: raise Exceptions.StackUnderflow, stack

    def lt([b, a | rest], _), do: [to_int(a < b) | rest]
    def lt(stack, _), do: raise Exceptions.StackUnderflow, stack

    def gt([b, a | rest], _), do: [to_int(a > b) | rest]
    def gt(stack, _), do: raise Exceptions.StackUnderflow, stack

    defp to_int(falsey) when falsey in [false, nil], do: 0
    defp to_int(_), do: 1
  end

  defmodule Logic do
    import Kernel, except: [if: 2]
    import Forth.Builtins.Internals

    def if([then, value | rest], _) do
      Kernel.if value != 0, do: block_eval(then, rest), else: rest
    end
    def if(stack, _), do: raise Exceptions.StackUnderflow, stack

    def ifnot([then, value | rest], _) do
      Kernel.if value == 0, do: block_eval(then, rest), else: rest
    end
    def ifnot(stack, _), do: raise Exceptions.StackUnderflow, stack
  end

  defmodule StackManipulation do
    import Forth.Builtins.Internals

    def dup([head | _] = stack, _), do: [head | stack]
    def dup(stack, _), do: raise Exceptions.StackUnderflow, stack

    def swap([b, a | rest], _), do: [a, b | rest]
    def swap(stack, _), do: raise Exceptions.StackUnderflow, stack

    def over([_b, a | _rest] = stack, _), do: [a | stack]
    def over(stack, _), do: raise Exceptions.StackUnderflow, stack

    def drop([_ | rest], _), do: rest
    def drop(stack, _), do: raise Exceptions.StackUnderflow, stack

    def call([{:compiled, block} | rest], closure),
      do: block_eval(block, rest, closure)
    def call(stack, _), do: raise Exceptions.StackUnderflow, stack

    def print([a | rest], _), do: (IO.puts(a); rest)
    def print(stack, _), do: raise Exceptions.StackUnderflow, stack
  end
end
