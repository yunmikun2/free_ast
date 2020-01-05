defmodule FreeAst.Program do
  @moduledoc false

  @enforce_keys [:program]
  defstruct [:program]

  @type t :: %__MODULE__{program: fun(1)}

  def new(fun) when is_function(fun, 1) do
    %__MODULE__{program: fun}
  end
end
