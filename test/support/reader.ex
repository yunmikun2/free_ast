defmodule FreeAstExample.Reader do
  @moduledoc false

  require FreeAst

  def read_line do
    FreeAst.p do
      effect IO, read_line()
    end
  end
end
