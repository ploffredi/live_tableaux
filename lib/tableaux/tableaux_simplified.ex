defmodule TableauxSimplified do
  use TableauxResolver

  import TableauxRules, only: [get_rule_type: 2, get_rule_expansion: 2, sort_queue: 1]
  import RuleExpansion, only: [closes_path?: 2, closed_path?: 1]

  @moduledoc """
  Documentation for `Simplified Tableaux`.
  """
  def is_valid?(sequent) do
    get_status(prove(sequent)) == :closed
  end

  defp get_simple_propositions(nodes) do
    nodes
    |> Enum.flat_map(fn n -> Expressions.to_simple_propositions(n.expression) end)
    |> Enum.uniq()
  end

  @impl true
  def prove(sequent) do
    parse =
      SequentParser.parse(sequent)
      |> sort()

    simple_propositions = get_simple_propositions(parse)

    case closed?(parse) do
      true ->
        %TableauxResolver{
          status: :closed,
          counterproof: nil,
          simple_propositions: simple_propositions
        }

      false ->
        closes_tr?([parse], %TableauxResolver{
          status: :closed,
          counterproof: to_counterproof(parse),
          simple_propositions: simple_propositions
        })
    end
  end

  def closes_tr?([], result) do
    result
  end

  def closes_tr?(
        _,
        %TableauxResolver{
          status: :open,
          counterproof: counterproof,
          simple_propositions: simple_propositions
        } = result
      ) do
    irrelevant_proofs =
      simple_propositions
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

  def closes_tr?([qh | qt], %TableauxResolver{simple_propositions: simple_propositions} = result) do
    [h | t] = qh

    {r, list} =
      cond do
        simple_proposition?(h) ->
          {%TableauxResolver{
             status: :open,
             counterproof: to_counterproof(qh),
             simple_propositions: simple_propositions
           }, []}

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
    %{expanded_nodes: expanded_nodes} = get_rule_expansion(n, 0)
    expanded_nodes
  end

  def expand_beta(n) do
    %{expanded_nodes: [n1, n2]} = get_rule_expansion(n, 0)
    # IO.inspect("#{n1.sign} #{n1.string} /\\ #{n2.sign} #{n2.string}")
    {n1, n2}
  end

  def closed?(l) do
    closed_path?(l)
  end

  def simple_proposition?(n) do
    get_rule_type(n.sign, n.expression) == :atom
  end

  def alpha?(n) do
    get_rule_type(n.sign, n.expression) == :alpha
  end

  def beta?(n) do
    get_rule_type(n.sign, n.expression) == :beta
  end

  def expand_and_cleanup(l, to_append) do
    if closed?(to_append) do
      []
    else
      if Enum.any?(to_append, fn n -> closes_path?(n, l) end) do
        []
      else
        to_append =
          to_append
          |> Enum.filter(fn el_a ->
            !Enum.any?(l, fn el_l -> el_l.sign == el_a.sign && el_l.string == el_a.string end)
          end)

        case to_append do
          [] ->
            l

          _ ->
            l
            |> Enum.concat(to_append)
            |> sort()
            |> Enum.uniq_by(fn el -> "#{el.sign} #{el.string}" end)
        end
      end
    end
  end

  def sort(l) do
    sort_queue(l)
  end

  def to_counterproof(l) do
    l
    |> Enum.map(fn
      %{sign: :T, expression: expr} -> {expr, true}
      %{sign: :F, expression: expr} -> {expr, false}
    end)
  end
end
