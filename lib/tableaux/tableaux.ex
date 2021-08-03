defmodule Tableaux do
  @moduledoc """
  Documentation for `Tableaux`.
  """

  @spec verify(binary()) :: boolean()
  def verify(sequent) do
    sequent
    |> expand_sequent()
    |> is_closed()
  end

  def is_valid?(sequent) do
    sequent
    |> expand_sequent()
    |> is_closed()
  end


  def expand_sequent(sequent) do
    nodes_list = SequentParser.parse(sequent) |> TableauxNode.to_tableaux_nodes(0, 1)
    expand(nil, nodes_list)
  end

  @spec expand(BinTree.t(), [TableauxNode.t()], [TableauxNode.t()]) :: BinTree.t()
  def expand(tree, to_apply, applied \\ [])

  def expand(tree, [], _), do: tree

  def expand(nil, to_apply, [] = _applied) do
    {:ok, expansion} = TableauxRules.get_first_expansion(to_apply)

    if RuleExpansion.closed_path(expansion.expanded_nodes) do
      RuleExpansion.expand(nil, expansion)
    else
      RuleExpansion.expand(nil, expansion)
      |> expand(to_apply, [])
    end
  end

  def expand(tree, to_apply, applied) do
    {:ok, expansion, expanded, remaining} = TableauxRules.get_expansion(to_apply, applied)

    RuleExpansion.expand(tree, expansion)
    |> expand(remaining ++ expansion.expanded_nodes, [expanded | applied])
  end

  def is_closed(nil) do
    true
  end

  def is_closed(%BinTree{value: %TableauxNode{closed: closed}, left: nil, right: nil}) do
    closed
  end

  def is_closed(%BinTree{left: left, right: right}) do
    is_closed(left) && is_closed(right)
  end

  @spec from_sequent(binary) :: BinTree.t()
  @doc ~S"""
  Parses the given `sequent` into a binary tree.
  """
  def from_sequent(sequent) do
    sequent |> parse_sequent() |> RuleExpansion.linear_branch_from_list()
  end

  @spec parse_sequent(binary) :: [TableauxNode.t()]
  def parse_sequent(sequent) do
    sequent |> SequentParser.parse() |> TableauxNode.to_tableaux_nodes(0, 1)
  end
end
