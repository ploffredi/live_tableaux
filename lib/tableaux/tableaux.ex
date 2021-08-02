defmodule Tableaux do
  @moduledoc """
  Documentation for `Tableaux`.
  """

  @spec verify(binary()) :: BinTree.t()
  def verify(sequent) do
    nodes_list = SequentParser.parse(sequent) |> to_tableaux_nodes(0, 1)

    BinTree.linear_branch_from_list(nodes_list)
    |> expand(nodes_list)
  end

  @spec expand(BinTree.t(), [TableauxNode.t()], [TableauxNode.t()]) :: BinTree.t()
  def expand(tree, to_apply, applied \\ [])

  def expand(tree, [], _), do: tree

  def expand(tree, to_apply, applied) do
    {:ok, expansion, expanded, remaining} = TableauxRules.get_expansion(to_apply, applied)

    RuleExpansion.expand(tree, expansion)
    |> expand(remaining ++ expansion.expanded_nodes, [expanded | applied])
  end

  @spec from_sequent(binary) :: BinTree.t()
  @doc ~S"""
  Parses the given `sequent` into a binary tree.
  """
  def from_sequent(sequent) do
    sequent |> parse_sequent() |> BinTree.linear_branch_from_list()
  end

  @spec parse_sequent(binary) :: [TableauxNode.t()]
  def parse_sequent(sequent) do
    sequent |> SequentParser.parse() |> to_tableaux_nodes(0, 1)
  end

  @spec to_tableaux_nodes([Expressions.t()], integer(), integer()) :: [TableauxNode.t()]
  defp to_tableaux_nodes([expression], step, idx) do
    [
      %TableauxNode{
        expression: expression,
        string: Expressions.expression_to_string(expression),
        sign: :F,
        step: step,
        nid: idx,
        source: nil
      }
    ]
  end

  defp to_tableaux_nodes([expression | t], step, idx) do
    [
      %TableauxNode{
        expression: expression,
        nid: idx,
        sign: :T,
        source: nil,
        step: step,
        string: Expressions.expression_to_string(expression)
      }
    ]
    ++
    to_tableaux_nodes(t, step, idx + 1)
  end
end
