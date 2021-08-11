defmodule Tableaux do
  @moduledoc """
  Implementation of the Analytic Tableaux method.
  """
  @doc """
  Hello world.

  ## Examples

      iex> Tableaux.prove("p->q, p |- q")
      true

      iex> Tableaux.prove("p->q, p |- t")
      false
  """
  @spec prove(String.t()) :: boolean()
  def prove(argument) do
    [head | tail] = Parser.parse(argument)

    is_valid?(BinTree.from_node(head), [], tail)
  end

  @spec is_valid?(BinTree.t(), [TreeNode.t()], [TreeNode.t()]) :: boolean()
  def is_valid?(tree, path, to_expand)

  def is_valid?(nil, _, _), do: true

  def is_valid?(%{left: nil, right: nil, value: value} = tree, path, to_expand) do
    # IO.inspect(tree)
    # IO.inspect(to_expand)
    # IO.puts("\n")

    cond do
      closed?(value, path) ->
        true

      Rules.can_expand?(value) ->
        # Expand the current node, add the expansions to the tree and the stack,
        # then call is_valid? on the new tree created from the expansions
        %{tree: expanded_tree, expansion: expanded} = Rules.apply_rule(value)

        new_to_expand = Enum.filter(expanded, &Rules.can_expand?/1)

        is_valid?(BinTree.add(tree, expanded_tree), path, new_to_expand ++ to_expand)

      Enum.empty?(to_expand) ->
        false

      true ->
        # Expand the first element from the stack, add the expansions to the tree and the stack,
        # then call is_valid? on the new tree created from the expansions
        [head | tail] = to_expand

        %{tree: expanded_tree, expansion: expanded} = Rules.apply_rule(head)

        new_to_expand = Enum.filter(expanded, &Rules.can_expand?/1) ++ tail

        is_valid?(BinTree.add(tree, expanded_tree), path, new_to_expand)
    end
  end

  def is_valid?(%{left: left, right: right, value: value}, path, to_expand) do
    if closed?(value, path) do
      true
    else
      is_valid?(left, [value | path], to_expand) and is_valid?(right, [value | path], to_expand)
    end
  end

  @spec closed?(TreeNode.formula(), [TreeNode.formula()]) :: boolean()
  def closed?(formula, path), do: Enum.any?(path, &contradiction?(formula, &1))

  @spec contradiction?(TreeNode.t(), TreeNode.t()) :: boolean()
  def contradiction?(%{sign: :F, formula: formula}, %{sign: :T, formula: formula}), do: true
  def contradiction?(%{sign: :T, formula: formula}, %{sign: :F, formula: formula}), do: true
  def contradiction?(_, _), do: false
end
