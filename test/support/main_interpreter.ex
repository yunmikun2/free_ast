defmodule FreeAstExample.MainInterpreter do
  @moduledoc false

  alias FreeAst.Interpreter
  alias FreeAstExample.{IOInterpreter, EnvironmentInterpreter}

  def interpreter do
    Interpreter.noop()
    |> Interpreter.compose(IO, &IOInterpreter.interpret/3)
    |> Interpreter.compose(Environment, &EnvironmentInterpreter.interpret/3)
  end
end
