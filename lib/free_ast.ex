defmodule FreeAst do
  @moduledoc """
  Implements something similar to Free Monad.

  ## Usage

  `FreeAst.p/1` macro returns a program that can be interpreted later.
  Expressions to interpret are specified with `effect/2` and `eval/1`
  calls. The first one is used to specify a desired effect, while the
  second one -- to evaluate another program.

  Here we define two functions that return programs with effects:

  #{FreeAst.DocHelpers.import_src!("test/support/reader.ex")}
  #{FreeAst.DocHelpers.import_src!("test/support/greater.ex")}

  Now we can define interpreters for these:

  #{FreeAst.DocHelpers.import_src!("test/support/io_interpreter.ex")}
  #{FreeAst.DocHelpers.import_src!("test/support/environment_interpreter.ex")}

  For our first program we can use the first interpreter, but for the second
  one we need both, so we compose interpreters:

  #{FreeAst.DocHelpers.import_src!("test/support/main_interpreter.ex")}

  So now we can execute it with `FreeAst.interpret/2`:

      iex(1)> alias FreeAstExample.{Greater, MainInterpreter}
      iex(2)> FreeAst.interpret(Greater.great(), MainInterpreter.interpreter())
      "Hi, John"
  """

  alias FreeAst.{Effect, Program}

  @typedoc """
  Interpreter is a function that takes three arguments: action kind which
  is an atom or an alias, action name which is an atom, and a list of
  arguments of the action.
  """
  @type interpreter :: fun(3)

  @typedoc """
  Represents a program (returned by `p/1` macro).
  """
  @type program :: Program.t() | Effect.t()

  @doc """
  Interprets a program with the supplied interpreter.
  """
  @spec interpret(program, interpreter) :: term
  def interpret(program, interpreter)

  def interpret(%FreeAst.Program{program: program}, interpreter)
      when is_function(interpreter, 3) do
    program.(interpreter)
  end

  def interpret(
        %FreeAst.Effect{kind: kind, name: name, args: args},
        interpreter
      )
      when is_function(interpreter, 3) do
    interpreter.(kind, name, args)
  end

  def interpret(_, interpreter) when is_function(interpreter, 3) do
    raise ArgumentError, """
    expected first argument to be a program or an effect
    """
  end

  def interpret(_, _) do
    raise ArgumentError, """
    expected an interpreter to take exactly three arguments: action kind, action
    name, and action attributes
    """
  end

  @doc """
  Short syntax for defining functions that return programs

  #{FreeAst.DocHelpers.import_src!("test/support/defast_example.ex")}

      iex(1)> import FreeAstExample.DefastExample
      iex(2)> import FreeAst.Interpreter, only: [noop: 0]
      iex(3)> result_v1 = FreeAst.interpret(program_v1(), noop())
      iex(4)> result_v2 = FreeAst.interpret(program_v2(), noop())
      iex(5)> result_v1 == result_v2
      true
  """
  defmacro defast(func_signature, do_body)

  defmacro defast({name, _, attrs}, do: body) when is_list(attrs) do
    quote do
      def unquote(name)(unquote_splicing(attrs)) do
        FreeAst.p do
          unquote(body)
        end
      end
    end
  end

  defmacro defast({name, _, _}, do: body) do
    quote do
      def unquote(name)() do
        FreeAst.p do
          unquote(body)
        end
      end
    end
  end

  @doc """
  Creates a program from the supplied code block.

      iex(1)> program =
      ...(1)>  FreeAst.p do
      ...(1)>    x = effect IO, read_line()
      ...(1)>    "Hi, " <> x
      ...(1)>  end
      iex(2)> FreeAst.interpret(program, fn IO, :read_line, [] -> "Kek" end)
      "Hi, Kek"
  """
  defmacro p(ast_in_do_block)

  defmacro p(do: prog) do
    body = Macro.postwalk(prog, &expand_directives/1)

    quote do
      # Note: the interpreter variable is used inside quoted expression
      # in expand_directives/1 function.
      FreeAst.Program.new(fn interpreter -> unquote(body) end)
    end
  end

  defmacro p(attrs) do
    raise ArgumentError,
          "Expected a program in do-block. Got: #{inspect(attrs)}"
  end

  defp expand_directives({:effect, _, [kind, {name, _, args}]})
       when is_atom(kind) and is_atom(name) and is_list(args) do
    quote do
      effect = Effect.new(unquote(kind), unquote(name), unquote(args))
      FreeAst.interpret(effect, interpreter)
    end
  end

  defp expand_directives(
         {:effect, _, [{:__aliases__, _, _} = kind, {name, _, args}]}
       )
       when is_atom(name) and is_list(args) do
    quote do
      effect = Effect.new(unquote(kind), unquote(name), unquote(args))
      FreeAst.interpret(effect, interpreter)
    end
  end

  defp expand_directives({:effect, _, args}) do
    IO.inspect(args)

    raise ArgumentError, """
    effect directive expects two arguments where first is an atom or an
    alias representing the kind of an effect, and the second one is a call
    that represents the action itself
    """
  end

  defp expand_directives({:eval, _, [expression]}) do
    quote do
      FreeAst.interpret(unquote(expression), interpreter)
    end
  end

  defp expand_directives({:eval, _, _}) do
    raise ArgumentError, """
    eval directive expects exactly one argument -- something that evaluates
    into a program
    """
  end

  defp expand_directives(ast) do
    ast
  end
end
