defmodule FreeAst.Effect do
  # Describes an effect that's applied in FreeAst.Program instance.
  @moduledoc false

  @enforce_keys [:kind, :name, :args]
  defstruct [:kind, :name, :args]

  @type t :: %__MODULE__{kind: atom, name: atom, args: [term]}

  # Create an effectfull value.
  @doc false
  def new(kind, name, args)
      when is_atom(kind) and is_atom(name) and is_list(args) do
    %__MODULE__{kind: kind, name: name, args: args}
  end
end
