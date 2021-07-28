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

  def get_rule_type(:F, :negation) , do: :alpha

  def get_rule_type(:T, :implication), do: :beta

  def get_rule_type(:F, :implication), do: :alpha

  def get_rule_type(:T, :conjunction), do: :alpha

  def get_rule_type(:F, :conjunction), do: :beta

  def get_rule_type(:T, :disjunction), do: :beta

  def get_rule_type(:F, :disjunction), do: :alpha

  def get_rule_type(:T, :atom), do: :atom

  def get_rule_type(:F, :atom), do: :atom

  def get_rule_expansion(%{sign: :F , value: {:conjunction, expr1, expr2}}) do
    {:ok, get_rule_type(:F, :conjunction),
      [
        %{sign: :F, string: Expressions.expression_to_string(expr1), value: expr1},
        %{sign: :F, string: Expressions.expression_to_string(expr2), value: expr2},
      ]
    }
  end


  def get_rule_expansion(%{sign: :T , value: {:implication, expr1, expr2}}) do
    {:ok, get_rule_type(:T, :implication),
      [
        %{sign: :F, string: Expressions.expression_to_string(expr1), value: expr1},
        %{sign: :T, string: Expressions.expression_to_string(expr2), value: expr2},
      ]
    }
  end

  def get_rule_expansion(%{sign: :T , value: {:disjunction, expr1, expr2}}) do
    {:ok, get_rule_type(:T, :disjunction),
      [
        %{sign: :T, string: Expressions.expression_to_string(expr1), value: expr1},
        %{sign: :T, string: Expressions.expression_to_string(expr2), value: expr2},
      ]
    }
  end

  def get_rule_expansion(%{sign: :F , value: {:implication, expr1, expr2}}) do
    {:ok, get_rule_type(:F, :implication),
      [
        %{sign: :T, string: Expressions.expression_to_string(expr1), value: expr1},
        %{sign: :F, string: Expressions.expression_to_string(expr2), value: expr2},
      ]
    }
  end

  def get_rule_expansion(%{sign: :F , value: {:disjunction, expr1, expr2}}) do
    {:ok, get_rule_type(:F, :disjunction),
      [
        %{sign: :F, string: Expressions.expression_to_string(expr1), value: expr1},
        %{sign: :F, string: Expressions.expression_to_string(expr2), value: expr2},
      ]
    }
  end

  def get_rule_expansion(%{sign: :T , value: {:conjunction, expr1, expr2}}) do
    {:ok, get_rule_type(:T, :conjunction),
      [
        %{sign: :T, string: Expressions.expression_to_string(expr1), value: expr1},
        %{sign: :T, string: Expressions.expression_to_string(expr2), value: expr2},
      ]
    }
  end

  def get_rule_expansion(%{sign: :F , string: _, value: {:negation, expr}}) do
    {:ok, get_rule_type(:F, :negation), [%{sign: :T, string: Expressions.expression_to_string(expr), value: expr}]}
  end

end
