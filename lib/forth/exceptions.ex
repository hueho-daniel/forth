defmodule Forth.Exceptions do
  defmodule DivisionByZero do
    defexception message: "division by zero"
  end

  defmodule StackUnderflow do
    defexception [:message]

    def exception(stack) do
      %__MODULE__{message: "not enough elements in: #{inspect stack}"}
    end
  end

  defmodule UnknownWord do
    defexception [:message]

    def exception(word) do
      %__MODULE__{message: "unknown word: #{word}"}
    end
  end

  defmodule InvalidWord do
    defexception [:message]

    def exception(word) do
      %__MODULE__{message: "invalid word: #{word} (#{inspect word, charlists: :as_lists})"}
    end
  end
end
