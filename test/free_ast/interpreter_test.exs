defmodule FreeAst.InterpreterTest do
  @moduledoc false

  use ExUnit.Case

  alias FreeAst.Interpreter

  describe "noop/1" do
    setup do
      [noop: Interpreter.noop()]
    end

    test "raises an argument error", %{noop: noop} do
      assert_raise ArgumentError, fn ->
        noop.(:any, :any, [])
      end
    end
  end

  describe "compose/2" do
    test "applies the last interpreter on the respective action kind" do
      interpreter =
        Interpreter.compose(Interpreter.noop(), :kind, fn :kind, :name, [] ->
          :the_action
        end)

      assert interpreter.(:kind, :name, []) == :the_action
    end

    test "applies the first interpreter in case the second doesn't match" do
      the_first = fn :first, :name, [] -> :the_first end
      the_second = fn :second, :name, [] -> :the_second end
      interpreter = Interpreter.compose(the_first, :second, the_second)
      assert interpreter.(:first, :name, []) == :the_first
    end

    test "falls back to noop interpreter in case nothing matches" do
      interpreter =
        Interpreter.compose(Interpreter.noop(), :kind, fn _, _, _ ->
          :implemented
        end)

      assert_raise ArgumentError, fn ->
        interpreter.(:any, :any, [])
      end
    end
  end
end
