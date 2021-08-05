defmodule RuleExpansion do
  @type rule :: :alpha | :beta | :atom
  @type t :: %RuleExpansion{
          rule_type: rule(),
          source_nid: integer(),
          expanded_nodes: [TableauxNode.t()]
        }

  defstruct [:rule_type, :source_nid, :expanded_nodes]

  def apply_expansion(tree, %RuleExpansion{rule_type: _, expanded_nodes: []}), do: tree

  def apply_expansion(tree, %RuleExpansion{
        rule_type: :beta,
        source_nid: nid,
        expanded_nodes: [left, right]
      }),
      do: expand_beta(tree, left, right, nid, false, [])

  def apply_expansion(tree, %RuleExpansion{
        rule_type: :alpha,
        source_nid: nid,
        expanded_nodes: nodes
      }),
      do: expand_alpha(tree, nodes, nid, false, [])

  @spec expand_alpha(nil | BinTree.t(), nil | [TableauxNode.t()], nil | integer(), boolean(), [
          TableauxNode.t()
        ]) ::
          BinTree.t() | nil



  defp expand_alpha(nil, list, _, _, []) do
    count = Enum.count(list)

    list
    |> Enum.with_index(fn
      n, ^count = _ -> %TableauxNode{n | closed: closes_path?(n, list)}
      n, _ -> n
    end)
    |> RuleExpansion.linear_branch_from_list()
  end

  defp expand_alpha(nil, _, _, _, _), do: nil

  defp expand_alpha(
         %BinTree{value: %TableauxNode{} = value, left: nil, right: nil} = tree,
         [],
         _ancestor,
         _ancestor_found,
         path
       ) do
    is_closed_path = closes_path?(value, path)
    %BinTree{tree | value: %TableauxNode{value | closed: is_closed_path}}
  end

  defp expand_alpha(
         %BinTree{value: %TableauxNode{nid: nid} = value, left: nil, right: nil} = tree,
         list,
         ancestor,
         ancestor_found,
         path
       ) do
    is_closed_path = closes_path?(value, path)

    if is_closed_path do
      %BinTree{tree | value: %TableauxNode{value | closed: true}, left: nil, right: nil}
    else
      if ancestor_found || nid == ancestor do
        closed_branch = Enum.any?(list, fn n -> closes_path?(n, [value | path]) end)

        branch =
          list
          |> Enum.map(fn n ->
            %TableauxNode{n | closed: closed_branch}
          end)
          |> RuleExpansion.linear_branch_from_list()

        if value.nid == 11 do
          # Enum.map(list, &"#{&1.sign} #{&1.string} [#{&1.source},#{&1.nid}]") |> IO.inspect(label: "branch")
          # IO.inspect("#{value.sign} #{value.string} [#{value.source}:#{value.nid}]")
          # IO.inspect(%BinTree{tree | left: branch})
        end

        %BinTree{tree | left: branch}
      else
        tree
      end
    end
  end

  defp expand_alpha(
         %BinTree{value: %TableauxNode{nid: nid} = value, left: left, right: right} = tree,
         list,
         ancestor,
         ancestor_found,
         path
       ) do
    if closes_path?(value, path) do
      %BinTree{
        tree
        | left: nil,
          right: nil,
          value: %TableauxNode{value | closed: true}
      }
    else
      %BinTree{
        tree
        | left:
            expand_alpha(left, list, ancestor, ancestor_found || nid == ancestor, [value | path]),
          right:
            expand_alpha(right, list, ancestor, ancestor_found || nid == ancestor, [value | path])
      }
    end
  end



  defp expand_beta(nil, _, _, _, _, _), do: nil

  defp expand_beta(
         %BinTree{value: %TableauxNode{nid: nid} = value, left: nil, right: nil} = tree,
         %TableauxNode{sign: _lsign, string: _lstr} = lnode,
         %TableauxNode{sign: _rsign, string: _rstr} = rnode,
         ancestor,
         ancestor_found,
         path
       ) do
    # Enum.map(path, &"#{&1.sign} #{&1.string} [#{&1.source},#{&1.nid}]") |> IO.inspect(label: "beta_leaf")
    is_closed_path = closes_path?(value, path)

    if is_closed_path do
      %BinTree{tree | value: %TableauxNode{value | closed: true}, left: nil, right: nil}
    else
      if ancestor_found || nid == ancestor do
        %BinTree{
          tree
          | left: %BinTree{
              value: %TableauxNode{lnode | closed: closes_path?(lnode, [value | path])}
            },
            right: %BinTree{
              value: %TableauxNode{rnode | closed: closes_path?(rnode, [value | path])}
            }
        }
      else
        tree
      end
    end
  end

  defp expand_beta(
         %BinTree{value: %TableauxNode{nid: nid} = value, left: left, right: right} = tree,
         lexp,
         rexp,
         ancestor,
         ancestor_found,
         path
       ) do
    # Enum.map(path, &"#{&1.sign} #{&1.string} [#{&1.source},#{&1.nid}]") |> IO.inspect(label: "beta")
    if closes_path?(value, path) do
      %BinTree{
        tree
        | left: nil,
          right: nil,
          value: %TableauxNode{value | closed: true}
      }
    else
      %BinTree{
        tree
        | left:
            expand_beta(left, lexp, rexp, ancestor, ancestor_found || nid == ancestor, [value | path]
            ),
          right:
            expand_beta(right, lexp, rexp, ancestor, ancestor_found || nid == ancestor, [
              value | path
            ])
      }
    end
  end

  @spec linear_branch_from_list([TableauxNode.t()]) :: BinTree.t()
  def linear_branch_from_list(list) do
    is_closed = closed_path?(list)
    linear_branch_from_list_rec(list, is_closed)
  end

  @spec linear_branch_from_list_rec([TableauxNode.t()], boolean()) :: BinTree.t()
  defp linear_branch_from_list_rec([], _), do: nil

  defp linear_branch_from_list_rec(
         [
           %TableauxNode{} = node
         ],
         true
       ),
       do: %BinTree{value: %TableauxNode{node | closed: true}}

  defp linear_branch_from_list_rec(
         [
           %TableauxNode{} = node
         ],
         _
       ),
       do: %BinTree{value: node}

  defp linear_branch_from_list_rec(
         [
           %TableauxNode{} = node | t
         ],
         closed
       ) do
    %BinTree{
      value: node,
      left: linear_branch_from_list_rec(t, closed)
    }
  end

  defp invert_sign(:T), do: :F
  defp invert_sign(:F), do: :T

  defp closes_path?(%TableauxNode{sign: sign, string: string}, lst) do
    Enum.any?(lst, fn e -> e.sign == invert_sign(sign) && e.string == string end)
  end

  def closed_path?([]), do: false

  def closed_path?([h | t]) do
    Enum.any?(t, fn e -> e.sign == invert_sign(h.sign) && e.string == h.string end) ||
      closed_path?(t)
  end
end
