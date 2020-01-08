defmodule FreeAst.Interpreter do
  @moduledoc """
  Helpers to work with interpreters.
  """

  @doc """
  Composes interpreters for different effect kinds

  Suppose you have two interpreters for two kinds of actions:

      defmodule MyApp.FileEffects do
        def interpret(_, :ls, [path]), do: File.ls(path)
      end

      defmodule MyApp.EnvEffects do
        def interpret(_, :some_variable, []) do
          Application.get_env(:my_app, :some_variable)
        end
      end

  Now you can compose it like this:

      defmodule MyApp.Effects do
        alias MyApp.{EnvEffects, FileEffects}

        def interpret(kind, action, attrs) do
          Effect.noop()
          |> Effect.compose(:file, &FileEffects.interpret/3)
          |> Effect.compose(:env, &EnvEffects.interpret/3)
          |> apply([kind, action, attrs])
        end
      end
  """
  def compose(interpreter, kind, interpreter_for_kind)
      when is_function(interpreter, 3) and is_function(interpreter_for_kind, 3) do
    fn
      ^kind, name, attrs -> interpreter_for_kind.(kind, name, attrs)
      kind, name, attrs -> interpreter.(kind, name, attrs)
    end
  end

  @doc """
  Empty effect interpreter; may be used to start effect interpreter composition

  See `compose/3` for more details.
  """
  def noop do
    fn kind, name, attrs ->
      raise ArgumentError,
            "Unknown effect of kind #{kind}: #{name}(#{
              attrs |> Enum.map(&to_string/1) |> Enum.join(", ")
            })"
    end
  end
end
