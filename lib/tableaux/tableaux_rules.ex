defmodule TableauxRules do
  @expansion_rules %{
    {:F, :atom} => {:atom, []},
    {:T, :atom} => {:atom, []},
    {:F, :conjunction} => {:beta, [:F, :F]},
    {:T, :implication} => {:beta, [:F, :T]},
    {:T, :disjunction} => {:beta, [:T, :T]},
    {:F, :implication} => {:alpha, [:T, :F]},
    {:F, :disjunction} => {:alpha, [:F, :F]},
    {:T, :conjunction} => {:alpha, [:T, :T]},
    {:F, :negation} => {:alpha, [:T]},
    {:T, :negation} => {:alpha, [:F]}
  }

  @spec compare_operators(atom(), atom()) :: boolean()
  def compare_operators(op, op), do: false
  def compare_operators(:alpha, _), do: true
  def compare_operators(:atom, _), do: false
  def compare_operators(_, :beta), do: true
  def compare_operators(_, _), do: false

  @spec get_rule_type(any, atom | {any, any} | {any, any, any}) :: any
  def get_rule_type(sign, {operator, _, _}),
    do: get_rule_type_op(sign, operator)

  def get_rule_type(sign, {operator, _}),
    do: get_rule_type_op(sign, operator)

  def get_rule_type(sign, atom) when is_atom(atom),
    do: get_rule_type_op(sign, :atom)

  defp get_rule_type_op(sign, operator) do
    {rule_type, _nodes_signs} = Map.get(@expansion_rules, {sign, operator})
    rule_type
  end

  def get_expansion(application_queue, history) do
    [to_expand | rest] =
      application_queue
      |> Enum.sort_by(&get_rule_type(&1.sign, &1.expression),&compare_operators(&1, &2))

      {:ok, get_rule_expansion(to_expand, Enum.count(application_queue) + Enum.count(history) + 1), to_expand , rest}
  end

  @spec get_rule_expansion(TableauxNode.t(), integer()) :: RuleExpansion.t()
  defp get_rule_expansion(
        %TableauxNode{
          sign: :F,
          expression: atom,
          nid: nid
        },
        _counter
      )
      when is_atom(atom),
      do: %RuleExpansion{
        rule_type: :alpha,
        source_nid: nid,
        expanded_nodes: []
      }

  defp get_rule_expansion(
        %TableauxNode{
          sign: :T,
          expression: atom,
          nid: nid
        },
        _counter
      )
      when is_atom(atom),
      do: %RuleExpansion{
        rule_type: :alpha,
        source_nid: nid,
        expanded_nodes: []
      }

  defp get_rule_expansion(
        %TableauxNode{
          sign: sign,
          expression: {operator, expr1, expr2},
          nid: nid
        },
        counter
      ) do
    {rule_type, nodes_signs} = Map.get(@expansion_rules, {sign, operator})

    %RuleExpansion{
      rule_type: rule_type,
      source_nid: nid,
      expanded_nodes:
        Enum.zip(nodes_signs, [{expr1, counter}, {expr2, counter + 1}])
        |> Enum.map(fn {s, {e, c}} ->
          %TableauxNode{
            sign: s,
            string: Expressions.expression_to_string(e),
            expression: e,
            source: nid,
            nid: c
          }
        end)
    }
  end

  defp get_rule_expansion(
        %TableauxNode{
          sign: sign,
          expression: {operator, expr1},
          nid: nid
        },
        counter
      ) do
    {rule_type, nodes_signs} = Map.get(@expansion_rules, {sign, operator})

    %RuleExpansion{
      rule_type: rule_type,
      source_nid: nid,
      expanded_nodes:
        Enum.zip(nodes_signs, [{expr1, counter}])
        |> Enum.map(fn {s, {e, c}} ->
          %TableauxNode{
            sign: s,
            string: Expressions.expression_to_string(e),
            expression: e,
            source: nid,
            nid: c
          }
        end)
    }
  end
end
