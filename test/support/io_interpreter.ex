defmodule FreeAstExample.IOInterpreter do
  @moduledoc false

  def interpret(IO, :read_line, []), do: "John"
end
