defmodule SequentParser do
  @spec parse(binary) :: [any | Expressions.t()]
  def parse(str) do
    {:ok, tokens, _} = str |> to_charlist() |> :sequent_lexer.string()
    {:ok, list} = :sequent_parser.parse(tokens)
    list
  end
end
