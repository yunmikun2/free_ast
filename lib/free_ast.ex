defmodule FreeAst do
  @moduledoc """
  Implements something similar to Free Monad.
  """

  @type interpreter :: fun(1)

  @doc """
  Interprets a program with the supplied interpreter.
  """
  @spec interpret(Program.t(), interpreter) :: term
  def interpret(program, interpreter)

  def interpret(%FreeAst.Program{program: program}, interpreter)
      when is_function(interpreter, 1) do
    program.(interpreter)
  end

  def interpret(%FreeAst.Program{}, _) do
    raise ArgumentError, """
    expected an interpreter to take exactly one argument
    """
  end

  def interpret(_, _) do
    raise ArgumentError, """
    expected first argument to be a program. Make sure you got the program from
    the p/1 macro
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
      unquote(binding) =
        case unquote(expression) do
          %FreeAst.Program{program: program} -> program.(interpreter)
          command -> interpreter.(command)
        end
    end
  end

  defp expand_let_bindings({:do_, _, [expression]}) do
    quote do
      case unquote(expression) do
        %FreeAst.Program{program: program} -> program.(interpreter)
        command -> interpreter.(command)
      end
    end
  end

  defp expand_let_bindings(ast) do
    ast
  end
end
