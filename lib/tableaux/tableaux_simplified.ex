defmodule TableauxSimplified do
  @moduledoc """
  Documentation for `Simplified Tableaux`.
  """

  def is_valid?(sequent) do
    SequentParser.parse(sequent)
    |> sort()
    |> closes?()
  end

  def closes?([h | t] = l) do
    cond do
      closed?(l) ->
        true

 #     unexpandable?(l) ->
 #       false

      atom?(h) ->
        false # (t ++ [h]) |> closes?()

      alpha?(h) ->
        nodes = expand_alpha(h)
        (t ++ nodes) |> cleanup() |> sort() |> closes?()

      beta?(h) ->
        {n1, n2} = expand_beta(h)
        closes?(([n1|t]) |> cleanup() |> sort()) && closes?(([n2|t]) |> cleanup() |> sort())

      true ->
        raise "unknown case"
    end
  end

  def expand_alpha(n) do
    %{expanded_nodes: expanded_nodes} = TableauxRules.get_rule_expansion(n, 0)
    expanded_nodes
  end

  def expand_beta(n) do
    %{expanded_nodes: [n1, n2]} = TableauxRules.get_rule_expansion(n, 0)
    {n1, n2}
  end

  def unexpandable?(l) do
    Enum.all?(l, fn n -> TableauxRules.get_rule_type(n.sign, n.expression) == :atom end)
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

  def cleanup(l) do
    Enum.uniq_by(l, fn el -> "#{el.sign} #{el.string}" end)
  end

  def sort(l) do
    TableauxRules.sort_queue(l)
  end
end
