defmodule Tableaux do
  use TableauxResolver

  @moduledoc """
  Documentation for `Tableaux`.
  """

  def is_valid?(sequent) do
    get_status(prove(sequent)) == :closed
  end

  @impl true
  def prove(sequent) do
    nodes_list = SequentParser.parse(sequent)
    simple_propositions = get_simple_propositions(nodes_list)

    expanded_tree = expand(nil, nodes_list)

    {is_closed, counterproof} =
      expanded_tree
      |> is_closed([])

    irrelevant_proofs =
      if is_closed do
        []
      else
        simple_propositions
        |> Enum.filter(fn atom -> !Enum.any?(counterproof, fn {cp, _} -> cp == atom end) end)
        |> Enum.map(fn a -> {a, true} end)
      end

    %TableauxResolver{
      status: if(is_closed, do: :closed, else: :open),
      simple_propositions: simple_propositions,
      counterproof: counterproof ++ irrelevant_proofs,
      expanded_tree: expanded_tree
    }
  end

  defp get_simple_propositions(nodes) do
    nodes
    |> Enum.flat_map(fn n -> Expressions.to_simple_propositions(n.expression) end)
    |> Enum.uniq()
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

  defp is_closed(nil, _counterproof) do
    {true, []}
  end

  defp is_closed(
         %BinTree{
           value: %TableauxNode{closed: closed} = value,
           left: nil,
           right: nil
         },
         counterproof
       )
       when is_boolean(closed) do
    if closed do
      {closed, []}
    else
      {closed, prepend_if_atom(value, counterproof)}
    end
  end

  defp is_closed(%BinTree{value: value, left: left, right: right}, counterproof) do
    {is_closed_left, cp_left} = is_closed(left, prepend_if_atom(value, counterproof))

    {is_closed_right, cp_right} = is_closed(right, prepend_if_atom(value, counterproof))

    case {is_closed_left, is_closed_right} do
      {true, true} -> {true, []}
      {false, _} -> {false, cp_left}
      {_, false} -> {false, cp_right}
    end
  end

  defp prepend_if_atom(%TableauxNode{expression: expr} = value, counterproof) do
    if is_atom(expr) do
      [node_to_proof(value) | counterproof] |> Enum.uniq()
    else
      counterproof
    end
  end

  defp node_to_proof(%TableauxNode{sign: :T, expression: atom}) when is_atom(atom) do
    {atom, true}
  end

  defp node_to_proof(%TableauxNode{sign: :F, expression: atom}) when is_atom(atom) do
    {atom, false}
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
