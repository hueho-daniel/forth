defmodule ForthTest do
  use ExUnit.Case
  doctest Forth

  # @tag :skip
  test "no input, no stack" do
    s = Forth.new
      |> Forth.format_stack
    assert s == ""
  end

  # @tag :skip
  test "push numbers into the stack" do
    s = Forth.new
      |> Forth.eval("1 2 3 4 5")
      |> Forth.format_stack
    assert s == "1 2 3 4 5"
  end

  # @tag :skip
  test "basic arithmetic" do
    s = Forth.new
        |> Forth.eval("1 2 + 4 -")
        |> Forth.format_stack
    assert s == "-1"

    s = Forth.new
        |> Forth.eval("2 4 * 3 /") # integer division
        |> Forth.format_stack
    assert s == "2"
  end

  # @tag :skip
  test "division by zero" do
    assert_raise Forth.Exceptions.DivisionByZero, fn ->
      Forth.new |> Forth.eval("4 2 2 - /")
    end
  end

  # @tag :skip
  test "dup" do
    s = Forth.new
      |> Forth.eval("1 DUP")
      |> Forth.format_stack
    assert s == "1 1"

    s = Forth.new
      |> Forth.eval("1 2 Dup")
      |> Forth.format_stack
    assert s == "1 2 2"

    assert_raise Forth.Exceptions.StackUnderflow, fn ->
      Forth.new |> Forth.eval("dup")
    end
  end

  # @tag :skip
  test "swap" do
    s = Forth.new
      |> Forth.eval("1 2 swap")
      |> Forth.format_stack
    assert s == "2 1"

    s = Forth.new
      |> Forth.eval("1 2 3 swap")
      |> Forth.format_stack
    assert s == "1 3 2"

    assert_raise Forth.Exceptions.StackUnderflow, fn ->
      Forth.new |> Forth.eval("1 swap")
    end

    assert_raise Forth.Exceptions.StackUnderflow, fn ->
      Forth.new |> Forth.eval("swap")
    end
  end

  # @tag :skip
  test "over" do
    s = Forth.new
      |> Forth.eval("1 2 over")
      |> Forth.format_stack
    assert s == "1 2 1"

    s = Forth.new
      |> Forth.eval("1 2 3 over")
      |> Forth.format_stack
    assert s == "1 2 3 2"

    assert_raise Forth.Exceptions.StackUnderflow, fn ->
      Forth.new |> Forth.eval("1 over")
    end

    assert_raise Forth.Exceptions.StackUnderflow, fn ->
      Forth.new |> Forth.eval("over")
    end
  end

  # @tag :skip
  test "defining a new word" do
    s = Forth.new
      |> Forth.eval(": dup-twice dup dup ;")
      |> Forth.eval("1 dup-twice")
      |> Forth.format_stack
    assert s == "1 1 1"
  end

  # @tag :skip
  test "redefining an existing word" do
    s = Forth.new
      |> Forth.eval(": foo dup ;")
      |> Forth.eval(": foo dup dup ;")
      |> Forth.eval("1 foo")
      |> Forth.format_stack
    assert s == "1 1 1"
  end

  # @tag :skip
  test "redefining an existing built-in word" do
    s = Forth.new
      |> Forth.eval(": swap dup ;")
      |> Forth.eval("1 swap")
      |> Forth.format_stack
    assert s == "1 1"
  end

  # @tag :skip
  test "defining words with odd characters" do
    s = Forth.new
      |> Forth.eval(": € 220371 ; €")
      |> Forth.format_stack
    assert s == "220371"
  end

  # @tag :skip
  test "defining a number" do
    assert_raise Forth.Exceptions.InvalidWord, fn ->
      Forth.new |> Forth.eval(": 1 2 ;")
    end
  end

  # @tag :skip
  test "calling a non-existing word" do
    assert_raise Forth.Exceptions.UnknownWord, fn ->
      Forth.new |> Forth.eval("1 foo")
    end
  end

  # @tag :skip
  test "calling a block" do
    s = Forth.new
      |> Forth.eval("[ 1 dup ]")
      |> Forth.eval("call")
      |> Forth.format_stack

    assert s == "1 1"
  end

  # @tag :skip
  test "using conditionals" do
    s = Forth.new
      |> Forth.eval("2 3 / 0 =")
      |> Forth.eval("[ 7 dup ] if")
      |> Forth.format_stack

    assert s == "7 7"
  end

  # @tag :skip
  test "nested blocks" do
    s = Forth.new
      |> Forth.eval("1 1 + [ dup + [ dup + ] call ] call")
      |> Forth.format_stack

    assert s == "8"
  end

  # @tag :skip
  test "empty block" do
    s = Forth.new
      |> Forth.eval("1 2 3 [] call")
      |> Forth.format_stack

    assert s == "1 2 3"
  end

  # @tag :skip
  test "capture on definition" do
    s = Forth.new
      |> Forth.eval(": mult (x y) x y *; 2 3 mult")
      |> Forth.format_stack

    assert s == "6"
  end

  # @tag :skip
  test "capture on block" do
    s = Forth.new
      |> Forth.eval(": square (x) x x *; 3 4 [(y z) y square z square +] call")
      |> Forth.format_stack

    assert s == "25"
  end
end
