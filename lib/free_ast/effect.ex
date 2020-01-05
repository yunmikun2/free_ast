defmodule FreeAst.Effect do
  @moduledoc """
  Describes an effect that's applied in FreeAst.Program instance.
  """

  @enforce_keys [:kind, :action]
  defstruct [:kind, :action]

  @type t :: %__MODULE__{kind: atom, action: term}

  @doc """
  Create an effectfull value.
  """
  def new(kind, action) when is_atom(kind) do
    %__MODULE__{kind: kind, action: action}
  end

  @doc """
  Composes interpreters for different effect kinds

  Suppose you have two interpreters for two kinds of actions:

      def interpreter1(:do1), do: # ...
      def interpreter2(:do2), do: # ...

  Now you can compose it like this:
      Effect.noop()
      |> Effect.compose(:do1, &interpret1/1)
      |> Effect.compose(:do2, &interpret2/1)
  """
  def compose(interpreter, kind, interpreter_for_kind)
      when is_function(interpreter, 2) and is_function(interpreter_for_kind, 1) do
    fn
      ^kind, name -> interpreter_for_kind.(name)
      kind, name -> interpreter.(kind, name)
    end
  end

  @doc """
  Empty effect interpreter; may be used to start effect interpreter composition

  See compose/3 for more details.
  """
  def noop do
    fn kind, _ -> raise ArgumentError, "Unknown effect of kind #{kind}" end
  end
end
