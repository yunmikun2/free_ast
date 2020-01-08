defmodule FreeAstExample.Greater do
  @moduledoc false

  require FreeAst

  alias FreeAstExample.Reader

  def great do
    FreeAst.p do
      greating = effect Environment, greating()
      greating <> ", " <> eval Reader.read_line()
    end
  end
end
