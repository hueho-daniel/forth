defmodule Forth do
  alias Forth.Builtins
  alias Forth.Exceptions

  alias Builtins.Arithmetic, as: BA
  alias Builtins.Logic, as: BL
  alias Builtins.StackManipulation, as: BSM

  defstruct stack: [], words: %{
    # Native arithmetic
    "+" => &BA.sum/2,
    "-" => &BA.sub/2,
    "*" => &BA.mul/2,
    "/" => &BA.div/2,
    "=" => &BA.eq/2,
    "<" => &BA.lt/2,
    ">" => &BA.gt/2,

    # Conditionals
    "if"    => &BL.if/2,
    "ifnot" => &BL.ifnot/2,

    # Forth functions
    "dup"   => &BSM.dup/2,
    "swap"  => &BSM.swap/2,
    "over"  => &BSM.over/2,
    "drop"  => &BSM.drop/2,
    "call"  => &BSM.call/2,
    "print" => &BSM.print/2
  }

  def new, do: %__MODULE__{}

  def format_stack(%__MODULE__{stack: stack}) do
    format_stack(stack)
  end

  def format_stack(stack) when is_list(stack) do
    stack |> Enum.reverse |> Enum.join("\s")
  end

  def eval(%__MODULE__{stack: stack, words: words}, command) do
    with {:ok, tokens, _} <- (command |> to_char_list |> :forth_lex.string),
         {:ok, program} <- :forth_parse.parse(tokens) do
      {new_stack, new_words} = do_eval(program, stack, words)
      %__MODULE__{stack: new_stack, words: new_words}
    else
      {:error, {_, :forth_parse, [_, [token]]}} ->
        raise Exceptions.InvalidWord, token
      {:error, {_, :forth_lex, {:illegal, token}}, _} ->
        raise Exceptions.InvalidWord, token
    end
  end

  defp do_eval([], stack, words),
    do: {stack, words}

  defp do_eval([{:word, word}|program], stack, words) do
    next_stack = case Map.fetch(words, word) do
      {:ok, fun} when is_function(fun) -> fun.(stack, %{})
      {:ok, block} -> Builtins.Internals.block_eval(block, stack, %{})
      :error -> raise Exceptions.UnknownWord, word
    end

    # do_eval(program, next_stack, words)
  end

  defp do_eval([{:def, new_word, {:block, capture, block}}|program], stack, words),
    do: do_eval(program, stack,
      Map.put(words, new_word, compile_block(block, capture, words)))
  
  defp do_eval([{:block, capture, block}|program], stack, words) when is_list(block),
    do: do_eval(program, [compile_block(block, capture, words) | stack], words)

  defp do_eval([term|program], stack, words),
    do: do_eval(program, [term | stack], words)

  defp compile_block(block, :no_capture, words),
    do: do_compile_block(block, words, [], [])

  defp compile_block(block, capture_list, words),
    do: do_compile_block(block, words, capture_list, [capture: capture_list])

  defp do_compile_block([], _, _, compiled), do: {:compiled, Enum.reverse(compiled)}
  defp do_compile_block([command | rest], words, capture_list, compiled) do
    next_term = case command do
      {:word, word} ->
        if word in capture_list do
          {:closure, word}
        else
          {:def, words[word] || raise(Exceptions.UnknownWord, word)}
        end
      {:block, capture, block} when is_list(block) ->
        compile_block(block, capture, words)
      term ->
        term
    end

    do_compile_block(rest, words, capture_list, [next_term | compiled])
  end

end
