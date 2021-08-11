defmodule TableauxSimplified do
  use TableauxResolver, TableauxSimplified

  @moduledoc """
  Documentation for `Simplified Tableaux`.
  """
  def is_valid?(sequent) do
    TableauxSimplified.get_status(prove(sequent)) == :closed
  end

  defp get_atoms(nodes) do
    nodes
    |> Enum.flat_map(fn n -> Expressions.expression_to_atom_list(n.expression) end)
    |> Enum.uniq()
  end

  @impl true
  def prove(sequent) do
    parse =
      SequentParser.parse(sequent)
      |> sort()

    atoms = get_atoms(parse)

    case closed?(parse) do
      true ->
        %TableauxResolver{status: :closed, counterproof: nil, atoms: atoms}

      false ->
        closes_tr?([parse], %TableauxResolver{
          status: :closed,
          counterproof: to_counterproof(parse),
          atoms: atoms
        })
    end
  end

  def closes_tr?([], result) do
    result
  end

  def closes_tr?(
        _,
        %TableauxResolver{status: :open, counterproof: counterproof, atoms: atoms} = result
      ) do
    irrelevant_proofs =
      atoms
      |> Enum.filter(fn atom -> !Enum.any?(counterproof, fn {cp, _} -> cp == atom end) end)
      |> Enum.map(fn a -> {a, true} end)

    %TableauxResolver{
      result
      | counterproof: counterproof ++ irrelevant_proofs
    }
  end

  def closes_tr?([[] | qt], result) do
    closes_tr?(qt, result)
  end

  def closes_tr?([qh | qt], %TableauxResolver{atoms: atoms} = result) do
    [h | t] = qh

    {r, list} =
      cond do
        atom?(h) ->
          {%TableauxResolver{status: :open, counterproof: to_counterproof(qh), atoms: atoms}, []}

        alpha?(h) ->
          nodes = expand_alpha(h)

          {result, [expand_and_cleanup(t, nodes)]}

        beta?(h) ->
          {n1, n2} = expand_beta(h)

          {result, [expand_and_cleanup(t, [n1]), expand_and_cleanup(t, [n2])]}

        true ->
          %{status: :unknown, counterproof: nil}
      end

    # list
    # |> Enum.map(fn lst -> Enum.map(lst, &"#{&1.sign} #{&1.string}") end)
    # |> IO.inspect(label: "applied")

    closes_tr?(Enum.concat(list, qt), r)
  end

  def expand_alpha(n) do
    %{expanded_nodes: expanded_nodes} = TableauxRules.get_rule_expansion(n, 0)
    expanded_nodes
  end

  def expand_beta(n) do
    %{expanded_nodes: [n1, n2]} = TableauxRules.get_rule_expansion(n, 0)
    # IO.inspect("#{n1.sign} #{n1.string} /\\ #{n2.sign} #{n2.string}")
    {n1, n2}
  end

  def closed?(l) do
    RuleExpansion.closed_path?(l)
  end

  def atom?(n) do
    TableauxRules.get_rule_type(n.sign, n.expression) == :atom
  end

  def alpha?(n) do
    TableauxRules.get_rule_type(n.sign, n.expression) == :alpha
  end

  def beta?(n) do
    TableauxRules.get_rule_type(n.sign, n.expression) == :beta
  end

  def expand_and_cleanup(l, to_append) do
    if closed?(to_append) do
      []
    else
      if Enum.any?(to_append, fn n -> RuleExpansion.closes_path?(n, l) end) do
        []
      else
        l
        |> Enum.concat(to_append)
        |> sort()
        |> Enum.uniq_by(fn el -> "#{el.sign} #{el.string}" end)
      end
    end
  end

  def sort(l) do
    TableauxRules.sort_queue(l)
  end

  def to_counterproof(l) do
    l
    |> Enum.map(fn
      %{sign: :T, expression: expr} -> {expr, true}
      %{sign: :F, expression: expr} -> {expr, false}
    end)
  end
end
