defmodule FreeAstExample.DefastExample do
  @moduledoc false

  import FreeAst, only: [defast: 2]

  require FreeAst

  defast program_v1 do
    :value
  end

  def program_v2 do
    FreeAst.p do
      :value
    end
  end
end
