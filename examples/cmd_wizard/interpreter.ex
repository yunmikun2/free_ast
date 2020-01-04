defmodule FreeAst.CmdWizard.Interpreter do
  @moduledoc false

  def interpret(:read_line) do
    :line |> IO.read() |> String.trim()
  end

  def interpret({:write_line, str}) do
    IO.write(str)
  end
end
