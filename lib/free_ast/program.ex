defmodule FreeAst.Program do
  @moduledoc false

  @enforce_keys [:program]
  defstruct [:program]

  @type t :: %__MODULE__{program: fun(1)}
end
