defmodule TableauxSimplified do
  use TableauxResolver

  @moduledoc """
  Documentation for `Simplified Tableaux`.
  """

  @impl true
  @spec is_valid?(binary) :: boolean
  def is_valid?(sequent) do
    parse = SequentParser.parse(sequent)

    if RuleExpansion.closed_path?(parse) do
      true
    else
      parse
      |> sort()
      |> closes?()
    end
  end

  def closes?([]) do
    true
  end

  def closes?([h | t]) do
    cond do
      # closed?(l) ->
      #  true

      #     unexpandable?(l) ->
      #       false

      atom?(h) ->
        # (t ++ [h]) |> closes?()
        false

      alpha?(h) ->
        nodes = expand_alpha(h)
        t |> append_and_cleanup(nodes) |> sort() |> closes?()

      beta?(h) ->
        {n1, n2} = expand_beta(h)

        children =
          Task.Supervisor.children(LiveTableaux.TaskSupervisor)
          |> Enum.count(fn pid -> Process.alive?(pid) end)

        if children < 20 do
          t1 =
            Task.Supervisor.async(LiveTableaux.TaskSupervisor, fn ->
              closes?([n1 | t] |> cleanup() |> sort())
            end)

          t2 =
            Task.Supervisor.async(LiveTableaux.TaskSupervisor, fn ->
              closes?([n2 | t] |> cleanup() |> sort())
            end)

          Task.await(t1, :infinity) && Task.await(t2, :infinity)
        else
          closes?([n1 | t] |> cleanup() |> sort()) && closes?([n2 | t] |> cleanup() |> sort())
        end

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

  # def closed?(l) do
  #  RuleExpansion.closed_path?(l)
  # end

  def atom?(n) do
    TableauxRules.get_rule_type(n.sign, n.expression) == :atom
  end

  def alpha?(n) do
    TableauxRules.get_rule_type(n.sign, n.expression) == :alpha
  end

  def beta?(n) do
    TableauxRules.get_rule_type(n.sign, n.expression) == :beta
  end

  def cleanup([h | t] = l) do
    if RuleExpansion.closes_path?(h, t) do
      []
    else
      Enum.uniq_by(l, fn el -> "#{el.sign} #{el.string}" end)
    end
  end

  def append_and_cleanup(l, additional_nodes) do
    if Enum.any?(additional_nodes, fn an -> RuleExpansion.closes_path?(an, l) end) do
      []
    else
      (l ++ additional_nodes)
      |> Enum.uniq_by(fn el -> "#{el.sign} #{el.string}" end)
    end
  end

  def sort(l) do
    TableauxRules.sort_queue(l)
  end
end
