defmodule BinTree do
  @type t :: %BinTree{
          value: TreeNode.t(),
          left: BinTree.t() | nil,
          right: BinTree.t() | nil
        }

  defstruct [:value, left: nil, right: nil]

  @spec linear_from_list([TreeNode.t()]) :: BinTree.t()
  def linear_from_list([]), do: nil

  def linear_from_list([head | tail]) do
    %BinTree{value: head, left: linear_from_list(tail)}
  end

  @spec branch_from_list([TreeNode.t()]) :: BinTree.t()
  def branch_from_list([]), do: nil

  def branch_from_list([left, right]) do
    %BinTree{value: nil, left: from_node(left), right: from_node(right)}
  end

  @spec from_node(TreeNode.t()) :: BinTree.t()
  def from_node(node) do
    %BinTree{value: node}
  end

  @spec add(BinTree.t(), BinTree.t()) :: BinTree.t()
  def add(%{left: nil, right: nil} = tree, %{value: nil, left: left, right: right}) do
    %BinTree{tree | left: left, right: right}
  end

  def add(%{left: nil, right: nil} = tree, branch) do
    %BinTree{tree | left: branch}
  end
end
