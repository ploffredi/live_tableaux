defmodule BinTree do
  @moduledoc """
  A node in a binary tree.

  `value` is the value of a node.
  `left` is the left subtree (nil if no subtree).
  `right` is the right subtree (nil if no subtree).
  """

  @type t :: %BinTree{value: any, left: t() | nil, right: t() | nil , checked: boolean(), sign: :T|:F, string: binary(), nid: binary()}

  defstruct [:value, :left, :right, :checked, :sign, :string, nid: UUID.uuid1()]

  def to_map(%BinTree{string: string, sign: sign, left: nil, right: nil}) do
    %{name: "#{sign} #{string}", children: []}
  end
  def to_map(%BinTree{string: string, sign: sign, left: left, right: nil}) do
    %{name: "#{sign} #{string}", children: [to_map(left)]}
  end

  def to_map(%BinTree{string: string, sign: sign,  left: nil, right: right}) do
    %{name: "#{sign} #{string}", children: [ to_map(right)]}
  end

  def to_map(%BinTree{string: string, sign: sign, left: left, right: right}) do
    %{name: "#{sign} #{string}", children: [to_map(left), to_map(right)]}
  end


  def linear_branch_from_list([%{sign: sign, value: value, string: string}]) do
    %BinTree{value: value, sign: sign, string: string, checked: false}
  end

  def linear_branch_from_list([%{sign: sign, value: value, string: string}|t]) do
    %BinTree{value: value, sign: sign, string: string, checked: false, left: linear_branch_from_list(t)}
  end


end

defimpl Inspect, for: BinTree do
  import Inspect.Algebra

  # A custom inspect instance purely for the tests, this makes error messages
  # much more readable.
  #
  # BinTree[value: 3, left: BinTree[value: 5, right: BinTree[value: 6]]] becomes (3:(5::(6::)):)
  def inspect(%BinTree{string: value, sign: sign, left: left, right: right}, opts) do
    concat([
      "(",
      to_doc("#{sign} #{value}", opts),
      ":",
      if(left, do: to_doc(left, opts), else: ""),
      ":",
      if(right, do: to_doc(right, opts), else: ""),
      ")"
    ])
  end
end
