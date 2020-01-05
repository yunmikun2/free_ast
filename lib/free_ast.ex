defmodule FreeAst do
  @moduledoc """
  Implements something similar to Free Monad.
  """

  alias FreeAst.{Effect, Program}

  @type interpreter :: fun(2)

  @doc """
  Interprets a program with the supplied interpreter.
  """
  @spec interpret(Program.t() | Effect.t(), interpreter) :: term
  def interpret(program, interpreter)

  def interpret(%FreeAst.Program{program: program}, interpreter)
      when is_function(interpreter, 2) do
    program.(interpreter)
  end

  def interpret(%FreeAst.Effect{kind: kind, action: action}, interpreter)
      when is_function(interpreter, 2) do
    interpreter.(kind, action)
  end

  def interpret(_, interpreter) when is_function(interpreter, 2) do
    raise ArgumentError, """
    expected first argument to be a program or an effect

    Make sure you got the program from the p/1 macro and that you do not use
    do_ or let directives on not effectfull values
    """
  end

  def interpret(_, _) do
    raise ArgumentError, """
    expected an interpreter to take exactly two arguments
    """
  end

  @doc """
  Creates a program from the supplied code do-block.

  ## Example

      iex(1)> program =
      ...(1)>  FreeAst.p do
      ...(1)>    let x = :read_line
      ...(1)>    "Hi, " <> x
      ...(1)>  end

      iex(2)> FreeAst.interpret(program, fn :read_line -> "Kek" end)
      Hi, Kek
      "Hi, Kek"
  """
  defmacro p(ast_in_do_block)

  defmacro p(do: prog) do
    body = Macro.postwalk(prog, &expand_let_bindings/1)

    quote do
      %FreeAst.Program{
        # Note: the interpreter variable is used inside quoted expression
        # in expand_let_bindings/1 function.
        program: fn interpreter -> unquote(body) end
      }
    end
  end

  defmacro p(attrs) do
    raise ArgumentError,
          "Expected a program in do-block. Got: #{inspect(attrs)}"
  end

  defp expand_let_bindings({:let, _, [{:=, _, [binding, expression]}]}) do
    quote do
      unquote(binding) = FreeAst.interpret(unquote(expression), interpreter)
    end
  end

  defp expand_let_bindings({:do_, _, [expression]}) do
    quote do
      FreeAst.interpret(unquote(expression), interpreter)
    end
  end

  defp expand_let_bindings(ast) do
    ast
  end
end
