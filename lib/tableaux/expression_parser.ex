defmodule ExpressionParser do


  @spec parse(binary) :: list
  def parse(str) do
    {:ok, tokens, _} = str |> to_charlist() |> :expression_lexer.string()
    IO.inspect(tokens)
    {:ok, list} = :expression_parser.parse(tokens)
    list
  end
end
