defmodule TableauxRules do
  @expansion_rules %{
    {:F, :atom} => {:alpha, []},
    {:T, :atom} => {:alpha, []},
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

  def get_rule_type(:T, :negation), do: :alpha

  def get_rule_type(:F, :negation), do: :alpha

  def get_rule_type(:T, :implication), do: :beta

  def get_rule_type(:F, :implication), do: :alpha

  def get_rule_type(:T, :conjunction), do: :alpha

  def get_rule_type(:F, :conjunction), do: :beta

  def get_rule_type(:T, :disjunction), do: :beta

  def get_rule_type(:F, :disjunction), do: :alpha

  def get_rule_type(:T, :atom), do: :atom

  def get_rule_type(:F, :atom), do: :atom

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
