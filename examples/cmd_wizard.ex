defmodule FreeAst.CmdWizard do
  @moduledoc false

  require FreeAst

  def read_line do
    :read_line
  end

  def read_integer do
    FreeAst.p do
      case Integer.parse(do_ read_line()) do
        {num, ""} -> {:ok, num}
        _ -> :error
      end
    end
  end

  def write_line(str) do
    {:write_line, str}
  end

  def ask_for_name do
    FreeAst.p do
      do_ write_line("What's your name? -- ")
      let input = read_line()

      if input == "" do
        do_ write_line("I need your name\n")
        do_ ask_for_name()
      else
        input
      end
    end
  end

  def ask_for_age do
    FreeAst.p do
      do_ write_line("How old are you? -- ")

      case do_ read_integer() do
        {:ok, age} when age > 0 and age < 150 ->
          age

        _ ->
          do_ write_line("It can't be an age\n")
          do_ ask_for_age()
      end
    end
  end

  def run do
    FreeAst.p do
      let username = ask_for_name()
      let age = ask_for_age()

      cond do
        age < 16 ->
          do_ write_line("Hey, #{username}, how's your school?")

        age > 40 ->
          do_ write_line("Hello, #{username}, I'm gonna just ask...")

        :otherwise ->
          do_ write_line("Hi, #{username}")
      end

      {:ok, username, age}
    end
  end
end
