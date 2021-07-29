defmodule TableauxRules do
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
        rule_type: get_rule_type(:F, :atom),
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
        rule_type: get_rule_type(:T, :atom),
        expanded_nodes: []
      }

  def get_rule_expansion(%RuleNode{
        sign: :F,
        expression: {:conjunction, expr1, expr2},
        nid: nid
      }),
      do: %RuleExpansion{
        rule_type: get_rule_type(:F, :conjunction),
        expanded_nodes: [
          %RuleNode{
            RuleNode.empty_with_nid()
            | sign: :F,
              string: Expressions.expression_to_string(expr1),
              expression: expr1,
              source: nid
          },
          %RuleNode{
            RuleNode.empty_with_nid()
            | sign: :F,
              string: Expressions.expression_to_string(expr2),
              expression: expr2,
              source: nid
          }
        ]
      }

  def get_rule_expansion(%RuleNode{
        sign: :T,
        expression: {:implication, expr1, expr2},
        nid: nid
      }),
      do: %RuleExpansion{
        rule_type: get_rule_type(:T, :implication),
        expanded_nodes: [
          %RuleNode{
            RuleNode.empty_with_nid()
            | sign: :F,
              string: Expressions.expression_to_string(expr1),
              expression: expr1,
              source: nid
          },
          %RuleNode{
            RuleNode.empty_with_nid()
            | sign: :T,
              string: Expressions.expression_to_string(expr2),
              expression: expr2,
              source: nid
          }
        ]
      }

  def get_rule_expansion(%RuleNode{
        sign: :T,
        expression: {:disjunction, expr1, expr2},
        nid: nid
      }),
      do: %RuleExpansion{
        rule_type: get_rule_type(:T, :disjunction),
        expanded_nodes: [
          %RuleNode{
            RuleNode.empty_with_nid()
            | sign: :T,
              string: Expressions.expression_to_string(expr1),
              expression: expr1,
              source: nid
          },
          %RuleNode{
            RuleNode.empty_with_nid()
            | sign: :T,
              string: Expressions.expression_to_string(expr2),
              expression: expr2,
              source: nid
          }
        ]
      }

  def get_rule_expansion(%RuleNode{
        sign: :F,
        expression: {:implication, expr1, expr2},
        nid: nid
      }),
      do: %RuleExpansion{
        rule_type: get_rule_type(:F, :implication),
        expanded_nodes: [
          %RuleNode{
            RuleNode.empty_with_nid()
            | sign: :T,
              string: Expressions.expression_to_string(expr1),
              expression: expr1,
              source: nid
          },
          %RuleNode{
            RuleNode.empty_with_nid()
            | sign: :F,
              string: Expressions.expression_to_string(expr2),
              expression: expr2,
              source: nid
          }
        ]
      }

  def get_rule_expansion(%RuleNode{
        sign: :F,
        expression: {:disjunction, expr1, expr2},
        nid: nid
      }),
      do: %RuleExpansion{
        rule_type: get_rule_type(:F, :disjunction),
        expanded_nodes: [
          %RuleNode{
            RuleNode.empty_with_nid()
            | sign: :F,
              string: Expressions.expression_to_string(expr1),
              expression: expr1,
              source: nid
          },
          %RuleNode{
            RuleNode.empty_with_nid()
            | sign: :F,
              string: Expressions.expression_to_string(expr2),
              expression: expr2,
              source: nid
          }
        ]
      }

  def get_rule_expansion(%RuleNode{
        sign: :T,
        expression: {:conjunction, expr1, expr2},
        nid: nid
      }),
      do: %RuleExpansion{
        rule_type: get_rule_type(:T, :conjunction),
        expanded_nodes: [
          %RuleNode{
            RuleNode.empty_with_nid()
            | sign: :T,
              string: Expressions.expression_to_string(expr1),
              expression: expr1,
              source: nid
          },
          %RuleNode{
            RuleNode.empty_with_nid()
            | sign: :T,
              string: Expressions.expression_to_string(expr2),
              expression: expr2,
              source: nid
          }
        ]
      }

  def get_rule_expansion(%RuleNode{
        sign: :F,
        string: _,
        expression: {:negation, expr},
        nid: nid
      }),
      do: %RuleExpansion{
        rule_type: get_rule_type(:F, :negation),
        expanded_nodes: [
          %RuleNode{
            RuleNode.empty_with_nid()
            | sign: :T,
              string: Expressions.expression_to_string(expr),
              expression: expr,
              source: nid
          }
        ]
      }

  def get_rule_expansion(%RuleNode{
        sign: :T,
        string: _,
        expression: {:negation, expr},
        nid: nid
      }),
      do: %RuleExpansion{
        rule_type: get_rule_type(:T, :negation),
        expanded_nodes: [
          %RuleNode{
            RuleNode.empty_with_nid()
            | sign: :F,
              string: Expressions.expression_to_string(expr),
              expression: expr,
              source: nid
          }
        ]
      }
end
