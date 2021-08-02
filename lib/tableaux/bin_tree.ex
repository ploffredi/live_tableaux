defmodule BinTree do
  @moduledoc """
  A node in a binary tree.

  `value` is the value of a node.
  `left` is the left subtree (nil if no subtree).
  `right` is the right subtree (nil if no subtree).
  """

  @node_color "rgb(0,240,0)"
  @leaf_color "rgb(240,0,0)"
  @closed_color "rgb(0,0,0)"

  @type t :: %BinTree{
          value: any,
          left: t() | nil,
          right: t() | nil
        }

  defstruct [:value, :left, :right]

  defp get_full_name(%BinTree{value: %TableauxNode{string: string, sign: sign, nid: nid, source: source}}) do
    source = if !is_nil(source), do: "#{source}:", else: ""
    "#{sign} #{string}    [#{source}#{nid}]"
  end

  def to_map(
        %BinTree{
          left: nil,
          right: nil,
          value: %TableauxNode{closed: closed }
        } = tree
      ) do
    if closed do
      %{name: get_full_name(tree), color: @closed_color, children: []}
    else
      %{name: get_full_name(tree), color: @leaf_color, children: []}
    end
  end

  def to_map(
        %BinTree{
          left: left,
          right: nil,
          value: %TableauxNode{closed: closed }
        } = tree
      ) do
    if closed do
      %{name: get_full_name(tree), color: @closed_color, children: [to_map(left)]}
    else
      %{name: get_full_name(tree), color: @node_color, children: [to_map(left)]}
    end
  end

  def to_map(
        %BinTree{
          left: nil,
          right: right,
          value: %TableauxNode{closed: closed }
        } = tree
      ) do
    if closed do
      %{name: get_full_name(tree), color: @closed_color, children: [to_map(right)]}
    else
      %{name: get_full_name(tree), color: @node_color, children: [to_map(right)]}
    end
  end

  def to_map(
        %BinTree{
          left: left,
          right: right,
          value: %TableauxNode{closed: closed }
        } = tree
      ) do
    if closed do
      %{name: get_full_name(tree), color: @closed_color, children: [to_map(left), to_map(right)]}
    else
      %{name: get_full_name(tree), color: @node_color, children: [to_map(left), to_map(right)]}
    end
  end
end

# defimpl Inspect, for: BinTree do
#  import Inspect.Algebra
#
#  # A custom inspect instance purely for the tests, this makes error messages
#  # much more readable.
#  #
#  # BinTree[value: 3, left: BinTree[value: 5, right: BinTree[value: 6]]] becomes (3:(5::(6::)):)
#  def inspect(%BinTree{string: value, sign: sign, left: left, right: right}, opts) do
#    concat([
#      "(",
#      to_doc("#{sign} #{value}", opts),
#      ":",
#      if(left, do: to_doc(left, opts), else: ""),
#      ":",
#      if(right, do: to_doc(right, opts), else: ""),
#      ")"
#    ])
#  end
# end
