defmodule Tableaux do
  @moduledoc """
  Documentation for `Tableaux`.
  """

  import Expression
  alias BinTree

  def verify(sequent) do
    from_sequent(sequent)
  end

  @spec from_sequent(binary) :: BinTree.t()
  @doc ~S"""
  Parses the given `sequent` into a binary tree.

  ## Examples

      iex> Tableaux.from_sequent("!(a|(b&c))>c,b|c,b|-c")
      ("T (¬(a∨(b∧c)))→c":("T b∨c":("T b":("F c"::):):):)

  """
  def from_sequent(sequent) do
    add_alpha_rules(nil, parse_sequent(sequent))
  end

  def parse_sequent(sequent) do
    SequentParser.parse(sequent) |> add_signs()
  end

  defp add_signs([expression]) do
    [%{value: expression, string: expression_to_string(expression), sign: :F}]
  end

  defp add_signs([expression|t]) do
    [%{value: expression, string: expression_to_string(expression), sign: :T} | add_signs(t)]
  end

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
