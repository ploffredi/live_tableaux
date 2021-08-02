defmodule RuleExpansion do

  @type rule :: :alpha | :beta | :atom
  @type t :: %RuleExpansion{
          rule_type: rule(),
          source_nid: integer() ,
          expanded_nodes: [TableauxNode.t()]
        }

  defstruct [:rule_type,:source_nid, :expanded_nodes]


  def expand(tree, %RuleExpansion{rule_type: :atom, expanded_nodes: _}) do
    tree
  end

  def expand(tree, %RuleExpansion{rule_type: :beta, source_nid: nid, expanded_nodes: [left, right]}) do
    expand_beta(tree, left, right, nid, false, [])
  end

  def expand(tree, %RuleExpansion{rule_type: :alpha, source_nid: nid, expanded_nodes: nodes}) do
    expand_alpha(tree, nodes, nid, false, [])
  end

  @spec expand_alpha(nil | BinTree.t(), [TableauxNode.t()], nil | binary(), boolean(), [binary()]) ::
          BinTree.t()
  @doc ~S"""
  Apply an alpha rules from tableaux to all the leaf nodes of a tree. The function is useful when you
  need to create the first tree after the sequent parsing
  """
  def expand_alpha(nil, _list, _ancestor, _ancestor_found, _path) do
    nil
  end

  def expand_alpha(
        %BinTree{value: %TableauxNode{nid: nid}=value, left: nil, right: nil} = tree,
        list,
        ancestor,
        ancestor_found,
        path
      ) do
    # Enum.map(path, &"#{&1.sign} #{&1.string} [#{&1.source},#{&1.nid}]") |> IO.inspect(label: "alpha_leaf")
    is_closed_path = closed_path(path)

    branch =
      list
      |> Enum.map(fn n ->
        %TableauxNode{n | closed: closes_path({n.sign, n.string}, [tree | path])}
      end)
      |> BinTree.linear_branch_from_list()

    case (ancestor_found || nid == ancestor) && !is_closed_path do
      true ->
        %BinTree{tree | left: branch}

      false ->
        if is_closed_path do
          %BinTree{ tree | value: %TableauxNode{value | closed: true } }
        else
          tree
        end
    end
  end

  def expand_alpha(
        %BinTree{value: %TableauxNode{nid: nid}=value, left: left, right: right} = tree,
        list,
        ancestor,
        ancestor_found,
        path
      ) do
    # Enum.map(path, &"#{&1.sign} #{&1.string} [#{&1.source},#{&1.nid}]") |> IO.inspect(label: "alpha")

    if closed_path(path) do
      %BinTree{
        tree
        | left: nil,
          right: nil,
          value: %TableauxNode{value | closed: true }
      }
    else
      %BinTree{
        tree
        | left:
            expand_alpha(left, list, ancestor, ancestor_found || nid == ancestor, [tree | path]),
          right:
            expand_alpha(right, list, ancestor, ancestor_found || nid == ancestor, [
              tree | path
            ])
      }
    end
  end

  @spec expand_beta(BinTree.t(), nil | TableauxNode.t(), nil | TableauxNode.t(), binary(), boolean(), [
          BinTree.t()
        ]) ::
          BinTree.t()
  @doc ~S"""
  Apply a beta rules from tableaux to all the leaf nodes of a tree.
  """

  def expand_beta(nil, _, _, _, _, _), do: nil

  def expand_beta(
        %BinTree{value: %TableauxNode{nid: nid}=value, left: nil, right: nil} = tree,
        %TableauxNode{sign: lsign, string: lstr} = lnode,
        %TableauxNode{sign: rsign, string: rstr} = rnode,
        ancestor,
        ancestor_found,
        path
      ) do
    # Enum.map(path, &"#{&1.sign} #{&1.string} [#{&1.source},#{&1.nid}]") |> IO.inspect(label: "beta_leaf")
    is_closed_path = closed_path(path)

    case (ancestor_found || nid == ancestor) && !is_closed_path do
      true ->
        %BinTree{
          tree
          | left: %BinTree{
              value: %TableauxNode{ lnode | closed: closes_path({lsign, lstr}, [tree | path])},
            },
            right: %BinTree{
              value: %TableauxNode{ rnode | closed: closes_path({rsign, rstr}, [tree | path])},
            }
        }

      false ->
        if is_closed_path do
          %BinTree{tree | value: %TableauxNode{value| closed: true} }
        else
          tree
        end
    end
  end

  def expand_beta(
        %BinTree{value: %TableauxNode{nid: nid}=value, left: left, right: right} = tree,
        lexp,
        rexp,
        ancestor,
        ancestor_found,
        path
      ) do
    # Enum.map(path, &"#{&1.sign} #{&1.string} [#{&1.source},#{&1.nid}]") |> IO.inspect(label: "beta")
    if closed_path(path) do
      %BinTree{
        tree
        | left: nil,
          right: nil,
          value: %TableauxNode{value| closed: true}
      }
    else
      %BinTree{
        tree
        | left:
            expand_beta(left, lexp, rexp, ancestor, ancestor_found || nid == ancestor, [
              tree | path
            ]),
          right:
            expand_beta(right, lexp, rexp, ancestor, ancestor_found || nid == ancestor, [
              tree | path
            ])
      }
    end
  end

  defp invert_sign(:T), do: :F
  defp invert_sign(:F), do: :T

  defp closes_path({sign, string}, lst) do
    Enum.any?(lst, fn e -> e.value.sign == invert_sign(sign) && e.value.string == string end)
    ||
    closed_path(lst)
  end

  defp closed_path([]), do: false

  defp closed_path([h | t]) do
    Enum.any?(t, fn e -> e.value.sign == invert_sign(h.value.sign) && e.value.string == h.value.string end) ||
      closed_path(t)
  end
end
