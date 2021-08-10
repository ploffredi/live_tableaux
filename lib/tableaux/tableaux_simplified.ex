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

    case closed?(parse) do
      true -> true
      false -> closes_tr?([parse], true)
    end
  end

  def closes_tr?([], result) do
    result
  end

  def closes_tr?([[] | qt], result) do
    closes_tr?(qt, result)
  end

  def closes_tr?([qh | qt], result) do
    [h | t] = qh

    {r, list} =
      cond do
        atom?(h) ->
          {false, []}

        alpha?(h) ->
          nodes = expand_alpha(h)

          {result, [expand_and_cleanup(t, nodes)]}

        beta?(h) ->
          {n1, n2} = expand_beta(h)

          {result, [expand_and_cleanup(t, [n1]), expand_and_cleanup(t, [n2])]}

        true ->
          {nil, []}
      end

    closes_tr?(list ++ qt, r)
  end

  def closes?([]) do
    true
  end

  def closes?([h | t]) do
    # Enum.map([h | t], fn n ->
    #  "#{n.sign} #{n.string}"
    # end)
    # |> Enum.join(" - ")
    # |> IO.inspect()

    cond do
      # closed?(l) ->
      # true

      #     unexpandable?(l) ->
      #       false

      atom?(h) ->
        # (t ++ [h]) |> closes?()
        false

      alpha?(h) ->
        nodes = expand_alpha(h)

        expand_and_cleanup(t, nodes) |> closes?()

      beta?(h) ->
        {n1, n2} = expand_beta(h)

        closes?(expand_and_cleanup(t, [n1])) &&
          closes?(expand_and_cleanup(t, [n2]))

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

  def cleanup(l) do
    Enum.uniq_by(l, fn el -> "#{el.sign} #{el.string}" end)
  end

  def sort(l) do
    TableauxRules.sort_queue(l)
  end
end
