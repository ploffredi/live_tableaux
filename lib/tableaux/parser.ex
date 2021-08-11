defmodule Parser do
  @moduledoc """
    Parser for propositional logic formulas
  """

  @spec parse(String.t()) :: list()
  def parse(input) do
    input
    |> String.split([",", "|-"])
    |> Enum.filter(fn x -> x != "" end)
    |> Enum.map(&parse_formula/1)
    |> create_nodes
  end

  @spec parse_formula(String.t()) :: tuple()
  defp parse_formula(input) do
    {:ok, tokens, _} = input |> String.to_charlist() |> :lexer.string()

    {:ok, result} = :parser.parse(tokens)

    result
  end

  @spec create_nodes([TreeNode.formula()]) :: [TreeNode.t()]
  defp create_nodes([formula | []]), do: [%TreeNode{formula: formula, sign: :F}]

  defp create_nodes([formula | tail]),
    do: [%TreeNode{formula: formula, sign: :T} | create_nodes(tail)]
end
