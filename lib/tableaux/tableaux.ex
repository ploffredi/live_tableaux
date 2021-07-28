defmodule Tableaux do
  @moduledoc """
  Documentation for `Tableaux`.
  """

  alias BinTree
  alias ExpressionParser

  def verify(sequent) do
    add_alpha_rules(nil, parse_sequent(sequent))
  end

  def from_sequent(sequent) do
    add_alpha_rules(nil, parse_sequent(sequent))
  end

  def parse_expression(expr) do
    %{string: expr, expression: expr |> ExpressionParser.parse()}
  end

  def parse_sequent(sequent) do
    sequent|> String.split([",","|-"]) |> Enum.map(&String.trim/1) |> Enum.map(&parse_expression/1) |> add_signs()
  end

  defp add_signs([%{string: string, expression: expression}]) do
    [%{value: expression, string: string, sign: :F}]
  end

  defp add_signs([%{string: string, expression: expression}|t]) do
    [%{value: expression, string: string, sign: :T} | add_signs(t)]
  end

  def linear_branch_from_list([%{sign: sign, value: value, string: string}]) do
    %BinTree{value: value, sign: sign, string: string, checked: false}
  end

  def linear_branch_from_list([%{sign: sign, value: value, string: string}|t]) do
    %BinTree{value: value, sign: sign, string: string, checked: false, left: linear_branch_from_list(t)}
  end

  def add_alpha_rules(nil, list) do
    linear_branch_from_list(list)
  end


  def add_alpha_rules(%BinTree{left: nil, right: nil}=tree, list) do
    %BinTree{tree | left: linear_branch_from_list(list)}
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
