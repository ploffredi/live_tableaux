defmodule Tableaux do
  @moduledoc """
  Documentation for `Tableaux`.
  """


  alias BinTree

  def verify(sequent) do
    signed_expressions_list=SequentParser.parse(sequent) |> add_signs()
    first_tree=add_alpha_rules(nil, signed_expressions_list)

    expand(first_tree, %{to_apply: signed_expressions_list, applied: []})
  end


  def expand(_tree, %{to_apply: to_apply, applied: _applied} ) do
    to_expand=to_apply|>Enum.sort_by(fn
      %{sign: sign , string: _, value: {operator, _, _}} -> TableauxRules.get_rule_type(sign, operator)
      %{sign: sign, string: _, value: {operator, _}} -> TableauxRules.get_rule_type(sign, operator)
      %{sign: sign, string: _, value: atom} when is_atom(atom) -> TableauxRules.get_rule_type(sign, :atom)
     end ,&TableauxRules.compare_operators(&1, &2))|>Enum.at(0)

     TableauxRules.get_rule_expansion(to_expand)

  end



  @spec from_sequent(binary) :: BinTree.t()
  @doc ~S"""
  Parses the given `sequent` into a binary tree.

  ## Examples

      iex> Tableaux.from_sequent("!(a|(b&c))>c,b|c,b|-c")
      %BinTree{
        checked: false,
        left: %BinTree{
          checked: false,
          left: %BinTree{
            checked: false,
            left: %BinTree{
              checked: false,
              left: nil,
              right: nil,
              sign: :F,
              string: "c",
              value: :c
            },
            right: nil,
            sign: :T,
            string: "b",
            value: :b
          },
          right: nil,
          sign: :T,
          string: "b∨c",
          value: {:disjunction, :b, :c}
        },
        right: nil,
        sign: :T,
        string: "(¬(a∨(b∧c)))→c",
        value: {:implication, {:negation, {:disjunction, :a, {:conjunction, :b, :c}}},
        :c}
      }

  """
  def from_sequent(sequent) do
    add_alpha_rules(nil, parse_sequent(sequent))
  end

  defp parse_sequent(sequent) do
    SequentParser.parse(sequent) |> add_signs()
  end

  def add_signs([expression]) do
    [%{value: expression, string: Expressions.expression_to_string(expression), sign: :F}]
  end

  def add_signs([expression|t]) do
    [%{value: expression, string: Expressions.expression_to_string(expression), sign: :T} | add_signs(t)]
  end

  @spec add_alpha_rules(nil | BinTree.t(), [
          %{:sign => any, :string => any, :value => any, optional(any) => any},
          ...
        ]) :: BinTree.t()

  @doc ~S"""
  Apply an alpha rules from tableaux to all the leaf nodes of a tree. The function is useful when you
  need to create the first tree after the sequent parsing

  ## Examples

      apply the alpha rule to an empty tree creates a tree with only left branches in all nodes

      iex> Tableaux.add_alpha_rules(nil, [%BinTree{value: :n1}, %BinTree{value: :n1}])
      %BinTree{
        checked: false,
        left: %BinTree{
          checked: false,
          left: nil,
          right: nil,
          sign: nil,
          string: nil,
          value: :n1
        },
        right: nil,
        sign: nil,
        string: nil,
        value: :n1
      }

  """
  def add_alpha_rules(nil, list) do
    BinTree.linear_branch_from_list(list)
  end

  def add_alpha_rules(%BinTree{left: nil, right: nil}=tree, list) do
    %BinTree{tree | left: BinTree.linear_branch_from_list(list)}
  end

  def add_alpha_rules(%BinTree{left: nil, right: right}=tree, list) do
    %BinTree{tree |
          right: add_alpha_rules(right, list)
        }
  end

  def add_alpha_rules(%BinTree{left: left, right: nil}=tree, list) do
    %BinTree{tree |
          left: add_alpha_rules(left, list)
        }
  end

  def add_alpha_rules(%BinTree{left: left, right: right}=tree, list) do
    %BinTree{tree |
          left: add_alpha_rules(left, list),
          right: add_alpha_rules(right, list)
        }
  end

  @spec add_beta_rules(
          BinTree.t(),
          %{:sign => any, :string => any, :value => any, optional(any) => any},
          %{:sign => any, :string => any, :value => any, optional(any) => any}
        ) :: BinTree.t()
  @doc ~S"""
  Apply a beta rules from tableaux to all the leaf nodes of a tree.

  ## Examples

      apply beta rules to a tree which have only one root node

      iex> Tableaux.add_beta_rules(%BinTree{value: :root}, %BinTree{value: :l1_left}, %BinTree{value: :l1_right})
      %BinTree{
        checked: nil,
        left: %BinTree{
          checked: false,
          left: nil,
          right: nil,
          sign: nil,
          string: nil,
          value: :l1_left
        },
        right: %BinTree{
          checked: false,
          left: nil,
          right: nil,
          sign: nil,
          string: nil,
          value: :l1_right
        },
        sign: nil,
        string: nil,
        value: :root
      }

      apply beta rules to a tree with two leaf on the first layer

      iex> Tableaux.add_beta_rules(%BinTree{value: :root, left: %BinTree{value: :l1_left}, right: %BinTree{value: :l1_right}}, %BinTree{value: :l2_left}, %BinTree{value: :l2_right})
      %BinTree{
        checked: nil,
        left: %BinTree{
          checked: nil,
          left: %BinTree{
            checked: false,
            left: nil,
            right: nil,
            sign: nil,
            string: nil,
            value: :l2_left
          },
          right: %BinTree{
            checked: false,
            left: nil,
            right: nil,
            sign: nil,
            string: nil,
            value: :l2_right
          },
          sign: nil,
          string: nil,
          value: :l1_left
        },
        right: %BinTree{
          checked: nil,
          left: %BinTree{
            checked: false,
            left: nil,
            right: nil,
            sign: nil,
            string: nil,
            value: :l2_left
          },
          right: %BinTree{
            checked: false,
            left: nil,
            right: nil,
            sign: nil,
            string: nil,
            value: :l2_right
          },
          sign: nil,
          string: nil,
          value: :l1_right
        },
        sign: nil,
        string: nil,
        value: :root
      }

  """
  def add_beta_rules(%BinTree{left: nil, right: nil}=tree, %{sign: lsign, value: lexp, string: lstr} , %{sign: rsign, value: rexp, string: lstr}) do
    %BinTree{tree | left: %BinTree{value: lexp, sign: lsign, string: lstr, checked: false}, right: %BinTree{value: rexp, sign: rsign, string: lstr, checked: false}}
  end

  def add_beta_rules(%BinTree{left: nil, right: right}=tree, lexp, rexp) do
    %BinTree{tree |
          right: add_beta_rules(right, lexp, rexp)
        }
  end

  def add_beta_rules(%BinTree{left: left, right: nil}=tree, lexp, rexp) do
    %BinTree{tree |
          left: add_beta_rules(left, lexp, rexp)
        }
  end

  def add_beta_rules(%BinTree{left: left, right: right}=tree, lexp, rexp) do
    %BinTree{tree |
          left: add_beta_rules(left,  lexp, rexp),
          right: add_beta_rules(right, lexp, rexp)
        }
  end
end
