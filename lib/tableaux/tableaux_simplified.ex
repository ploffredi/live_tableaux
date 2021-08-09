defmodule TableauxSimplified do
  use TableauxResolver

  @moduledoc """
  Documentation for `Simplified Tableaux`.
  """

  @impl true
  @spec is_valid?(binary) :: boolean
  def is_valid?(sequent) do
    parse =
      SequentParser.parse(sequent)
      |> sort()

    closes?([parse], true)
  end

  def closes?([], result) do
    result
  end

  def closes?(_, false) do
    false
  end

  def closes?([qh | qt], _) do
    [h | t] = qh

    {r, to_enqueue} =
      cond do
        closed?([h | t]) ->
          {true, []}

        atom?(h) ->
          # (t ++ [h]) |> closes?()
          {false, []}

        alpha?(h) ->
          nodes = expand_alpha(h)

          {true, [(nodes ++ t) |> cleanup()]}

        beta?(h) ->
          {n1, n2} = expand_beta(h)

          l1 = t ++ n1
          l2 = t ++ n2

          {true, [cleanup(l1), cleanup(l2)]}

        true ->
          {nil, nil}
      end

    closes?(to_enqueue ++ qt, r)
  end

  def expand_alpha(n) do
    %{expanded_nodes: expanded_nodes} = TableauxRules.get_rule_expansion(n, 0)
    expanded_nodes
  end

  def expand_beta(n) do
    %{expanded_nodes: [n1, n2]} = TableauxRules.get_rule_expansion(n, 0)
    {n1, n2}
  end

  # def unexpandable?(l) do
  #   Enum.all?(l, fn n -> TableauxRules.get_rule_type(n.sign, n.expression) == :atom end)
  # end

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

  def cleanup(l) do
    IO.inspect(l, label: "test")
    Enum.uniq_by(l, fn el -> "#{el.sign} #{el.string}" end)
  end

  def sort(l) do
    TableauxRules.sort_queue(l)
  end
end
