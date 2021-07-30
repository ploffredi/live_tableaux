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

  def compare_operators(first, second) do
    case first do
      :atom ->
        case second do
          :atom -> false
          :alpha -> false
          :beta -> false
        end

      :alpha ->
        case second do
          :atom -> true
          :alpha -> false
          :beta -> true
        end

      :beta ->
        case second do
          :atom -> true
          :alpha -> false
          :beta -> false
        end
    end
  end

  defp get_rule_type_op(sign, operator) do
    {rule_type, _nodes_signs} = Map.get(@expansion_rules, {sign, operator})
    rule_type
  end

  @spec get_rule_type(any, atom | {any, any} | {any, any, any}) :: any
  def get_rule_type(sign, {operator, _, _}),
    do: get_rule_type_op(sign, operator)

  def get_rule_type(sign, {operator, _}),
    do: get_rule_type_op(sign, operator)

  def get_rule_type(sign, atom) when is_atom(atom),
    do: get_rule_type_op(sign, :atom)

  @spec get_rule_expansion(RuleNode.t()) :: RuleExpansion.t()
  def get_rule_expansion(%RuleNode{
        sign: :F,
        string: _,
        expression: atom,
        nid: _nid
      })
      when is_atom(atom),
      do: %RuleExpansion{
        rule_type: :alpha,
        expanded_nodes: []
      }

  def get_rule_expansion(%RuleNode{
        sign: :T,
        string: _,
        expression: atom,
        nid: _nid
      })
      when is_atom(atom),
      do: %RuleExpansion{
        rule_type: :alpha,
        expanded_nodes: []
      }

  def get_rule_expansion(%RuleNode{
        sign: sign,
        expression: {operator, expr1, expr2},
        nid: nid
      }) do
    {rule_type, nodes_signs} = Map.get(@expansion_rules, {sign, operator})

    %RuleExpansion{
      rule_type: rule_type,
      expanded_nodes:
        Enum.zip(nodes_signs, [expr1, expr2])
        |> Enum.map(fn {s, e} ->
          %RuleNode{
            RuleNode.empty_with_nid()
            | sign: s,
              string: Expressions.expression_to_string(e),
              expression: e,
              source: nid
          }
        end)
    }
  end

  def get_rule_expansion(%RuleNode{
        sign: sign,
        expression: {operator, expr1},
        nid: nid
      }) do
    {rule_type, nodes_signs} = Map.get(@expansion_rules, {sign, operator})

    %RuleExpansion{
      rule_type: rule_type,
      expanded_nodes:
        Enum.zip(nodes_signs, [expr1])
        |> Enum.map(fn {s, e} ->
          %RuleNode{
            RuleNode.empty_with_nid()
            | sign: s,
              string: Expressions.expression_to_string(e),
              expression: e,
              source: nid
          }
        end)
    }
  end
end
