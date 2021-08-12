defmodule Tableaux do
  use TableauxResolver

  @moduledoc """
  Documentation for `Tableaux`.
  """

  @spec verify(binary()) :: boolean()
  def verify(sequent) do
    sequent
    |> expand_sequent()
    |> is_closed()
  end

  def prove(sequent) do
    sequent
    |> expand_sequent()
    |> is_closed()
  end

  def is_valid?(sequent) do
    sequent
    |> expand_sequent()
    |> is_closed()
  end

  @impl true
  def prove(_sequent) do
    nil
  end

  def expand_sequent(sequent) do
    nodes_list = SequentParser.parse(sequent)
    expand(nil, nodes_list)
  end

  defp expand(tree, to_apply, applied \\ [])

  defp expand(tree, [], _), do: tree

  defp expand(nil, to_apply, [] = _applied) do
    case RuleExpansion.closed_path?(to_apply) do
      true -> RuleExpansion.linear_branch_from_list(to_apply)
      false -> RuleExpansion.linear_branch_from_list(to_apply) |> expand(to_apply, [])
    end
  end

  defp expand(tree, to_apply, applied) do
    {:ok, expansion, expanded, remaining} = TableauxRules.get_expansion(to_apply, applied)

    RuleExpansion.apply_expansion(tree, expansion)
    |> expand(remaining ++ expansion.expanded_nodes, [expanded | applied])
  end

  defp is_closed(nil) do
    true
  end

  defp is_closed(%BinTree{value: %TableauxNode{closed: closed}, left: nil, right: nil})
       when is_boolean(closed) do
    closed
  end

  defp is_closed(%BinTree{left: left, right: right}) do
    is_closed(left) and is_closed(right)
  end

  @spec from_sequent(binary()) :: BinTree.t()
  @doc ~S"""
  Parses the given `sequent` into a binary tree.
  """
  def from_sequent(sequent) do
    sequent |> parse_sequent() |> RuleExpansion.linear_branch_from_list()
  end

  @spec parse_sequent(binary) :: [TableauxNode.t()]
  def parse_sequent(sequent) do
    sequent |> SequentParser.parse()
  end
end
