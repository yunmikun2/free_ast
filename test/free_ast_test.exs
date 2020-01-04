defmodule FreeAstTest do
  use ExUnit.Case

  require FreeAst

  test "" do
    prog = id(2)
    assert 4 == FreeAst.interpret(prog, fn x -> x + 2 end)
  end

  defp id(x) do
    FreeAst.p do
      let y = x
      y
    end
  end
end
