defmodule Rules do
  @moduledoc """
  Tableaux expansion rules
  """

  def apply_rule(formula) do
    type = get_type(formula)
    expansion = get_expansion(formula)

    case type do
      :linear ->
        %{
          tree: BinTree.linear_from_list(expansion),
          expansion: expansion
        }

      :branch ->
        %{
          tree: BinTree.branch_from_list(expansion),
          expansion: expansion
        }

      :atom ->
        %{
          tree: BinTree.from_node(expansion),
          expansion: []
        }
    end
  end

  def can_expand?(formula) do
    case get_type(formula) do
      :atom -> false
      _ -> true
    end
  end

  # Tp&q => Tp, Tq
  defp get_expansion(%{sign: :T, formula: {:and, a, b}}) do
    [
      %TreeNode{sign: :T, formula: a},
      %TreeNode{sign: :T, formula: b}
    ]
  end

  # Fp&q => Fp . Fq
  defp get_expansion(%{sign: :F, formula: {:and, a, b}}) do
    [
      %TreeNode{sign: :F, formula: a},
      %TreeNode{sign: :F, formula: b}
    ]
  end

  # Tp|q => Tp . Fq
  defp get_expansion(%{sign: :T, formula: {:or, a, b}}) do
    [
      %TreeNode{sign: :T, formula: a},
      %TreeNode{sign: :T, formula: b}
    ]
  end

  # Fp|q => Fp,  Fq
  defp get_expansion(%{sign: :F, formula: {:or, a, b}}) do
    [
      %TreeNode{sign: :F, formula: a},
      %TreeNode{sign: :F, formula: b}
    ]
  end

  # Tp->q => Fp . Tq
  defp get_expansion(%{sign: :T, formula: {:implies, a, b}}) do
    [
      %TreeNode{sign: :F, formula: a},
      %TreeNode{sign: :T, formula: b}
    ]
  end

  # Fp->q => Tp, Fq
  defp get_expansion(%{sign: :F, formula: {:implies, a, b}}) do
    [%TreeNode{sign: :T, formula: a}, %TreeNode{sign: :F, formula: b}]
  end

  # T!p => Fp
  defp get_expansion(%{sign: :T, formula: {:not, a}}) do
    [%TreeNode{sign: :F, formula: a}]
  end

  # F!p => Tp
  defp get_expansion(%{sign: :F, formula: {:not, a}}) do
    [%TreeNode{sign: :T, formula: a}]
  end

  # F/T p => F/T p
  defp get_expansion(%{formula: _} = formula), do: formula

  defp get_type(%{sign: :T, formula: {:and, _, _}}), do: :linear
  defp get_type(%{sign: :F, formula: {:and, _, _}}), do: :branch
  defp get_type(%{sign: :T, formula: {:or, _, _}}), do: :branch
  defp get_type(%{sign: :F, formula: {:or, _, _}}), do: :linear
  defp get_type(%{sign: :T, formula: {:implies, _, _}}), do: :branch
  defp get_type(%{sign: :F, formula: {:implies, _, _}}), do: :linear
  defp get_type(%{sign: :T, formula: {:not, _}}), do: :linear
  defp get_type(%{sign: :F, formula: {:not, _}}), do: :linear
  defp get_type(%{formula: _}), do: :atom
end
