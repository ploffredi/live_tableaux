defmodule BinTree do
  @moduledoc """
  A node in a binary tree.

  `value` is the value of a node.
  `left` is the left subtree (nil if no subtree).
  `right` is the right subtree (nil if no subtree).
  """

  @type t :: %BinTree{
          value: any,
          left: t() | nil,
          right: t() | nil,
          sign: :T | :F,
          string: binary(),
          nid: binary(),
          source: binary()
        }

  defstruct [:value, :left, :right, :sign, :string, nid: nil, source: nil]

  def to_map(%BinTree{string: string, sign: sign, left: nil, right: nil, nid: nid, source: source}) do
    %{name: "#{sign} #{string}  (#{source}->#{nid})", children: []}
  end

  def to_map(%BinTree{
        string: string,
        sign: sign,
        left: left,
        right: nil,
        nid: nid,
        source: source
      }) do
    %{name: "#{sign} #{string}  (#{source}->#{nid})", children: [to_map(left)]}
  end

  def to_map(%BinTree{
        string: string,
        sign: sign,
        left: nil,
        right: right,
        nid: nid,
        source: source
      }) do
    %{name: "#{sign} #{string}  (#{source}->#{nid})", children: [to_map(right)]}
  end

  def to_map(%BinTree{
        string: string,
        sign: sign,
        left: left,
        right: right,
        nid: nid,
        source: source
      }) do
    %{name: "#{sign} #{string}  (#{source}->#{nid})", children: [to_map(left), to_map(right)]}
  end

  @spec linear_branch_from_list([RuleNode.t()]) :: BinTree.t()
  def linear_branch_from_list([]), do: nil

  def linear_branch_from_list([
        %RuleNode{sign: sign, expression: value, string: string, nid: nid, source: source}
      ]),
      do: %BinTree{value: value, sign: sign, string: string, nid: nid, source: source}

  def linear_branch_from_list([
        %RuleNode{sign: sign, expression: value, string: string, nid: nid, source: source} | t
      ]),
      do: %BinTree{
        value: value,
        sign: sign,
        string: string,
        left: linear_branch_from_list(t),
        nid: nid,
        source: source
      }
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
