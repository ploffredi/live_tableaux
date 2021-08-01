defmodule Tableaux do
  @moduledoc """
  Documentation for `Tableaux`.
  """

  @spec add_signs(
          [
            Expressions.expr()
          ],
          integer(),
          integer()
        ) :: [TableauxNode.t()]
  def add_signs([expression], step, idx) do
    [
      %TableauxNode{
        expression: expression,
        string: Expressions.expression_to_string(expression),
        sign: :F,
        step: step,
        nid: idx,
        source: nil
      }
    ]
  end

  def add_signs([expression | t], step, idx) do
    [
      %TableauxNode{
        expression: expression,
        nid: idx,
        sign: :T,
        source: nil,
        step: step,
        string: Expressions.expression_to_string(expression)
      }
    ] ++
      add_signs(t, step, idx + 1)
  end

  @spec verify(binary()) :: BinTree.t()
  def verify(sequent) do
    signed_expressions_list = SequentParser.parse(sequent) |> add_signs(0, 1)
    first_tree = BinTree.linear_branch_from_list(signed_expressions_list)
    expand(first_tree, signed_expressions_list)
  end

  @spec expand(BinTree.t(), [TableauxNode.t()], [TableauxNode.t()]) :: BinTree.t()
  def expand(tree, to_apply, applied \\ [])

  def expand(tree, [], _), do: tree

  def expand(tree, to_apply, applied) do
    [to_expand | rest] =
      to_apply
      |> Enum.sort_by(
        &TableauxRules.get_rule_type(&1.sign, &1.expression),
        &TableauxRules.compare_operators(&1, &2)
      )

    expansion =
      TableauxRules.get_rule_expansion(to_expand, Enum.count(to_apply) + Enum.count(applied) + 1)

    case expansion.rule_type do
      :alpha ->
        add_alpha_rules(tree, expansion.expanded_nodes, to_expand.nid, false, [tree])

      :beta ->
        add_beta_rules_list(tree, expansion.expanded_nodes, to_expand.nid, [tree])

      :atom ->
        tree
    end
    |> expand(rest ++ expansion.expanded_nodes, [to_expand | applied])
  end

  @spec from_sequent(binary) :: BinTree.t()
  @doc ~S"""
  Parses the given `sequent` into a binary tree.
  """
  def from_sequent(sequent) do
    sequent |> parse_sequent() |> BinTree.linear_branch_from_list()
  end

  @spec parse_sequent(binary) :: [TableauxNode.t()]
  def parse_sequent(sequent) do
    sequent |> SequentParser.parse() |> add_signs(0, 1)
  end

  defp invert_sign(:T), do: :F
  defp invert_sign(:F), do: :T

  defp closes_path({sign, string}, lst) do
    Enum.any?(lst, fn e -> e.sign == invert_sign(sign) && e.string == string end)
    ||
    closed_path(lst)
  end

  defp closed_path([]), do: false

  defp closed_path([h | t]) do
    Enum.any?(t, fn e -> e.sign == invert_sign(h.sign) && e.string == h.string end) ||
      closed_path(t)
  end

  @spec add_alpha_rules(nil | BinTree.t(), [TableauxNode.t()], nil | binary(), boolean(), [binary()]) ::
          BinTree.t()
  @doc ~S"""
  Apply an alpha rules from tableaux to all the leaf nodes of a tree. The function is useful when you
  need to create the first tree after the sequent parsing
  """
  def add_alpha_rules(nil, _list, _ancestor, _ancestor_found, _path) do
    nil
  end

  def add_alpha_rules(
        %BinTree{nid: nid, left: nil, right: nil} = tree,
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
          %BinTree{tree | closed: true}
        else
          tree
        end
    end
  end

  def add_alpha_rules(
        %BinTree{nid: nid, left: left, right: right} = tree,
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
          closed: true
      }
    else
      %BinTree{
        tree
        | left:
            add_alpha_rules(left, list, ancestor, ancestor_found || nid == ancestor, [tree | path]),
          right:
            add_alpha_rules(right, list, ancestor, ancestor_found || nid == ancestor, [
              tree | path
            ])
      }
    end
  end

  @spec add_beta_rules_list(BinTree.t(), [nil | TableauxNode.t()], binary(), [BinTree.t()]) ::
          BinTree.t()
  defp add_beta_rules_list(tree, [left, right], ancestor, path) do
    add_beta_rules(tree, left, right, ancestor, false, path)
  end

  @spec add_beta_rules(BinTree.t(), nil | TableauxNode.t(), nil | TableauxNode.t(), binary(), boolean(), [
          BinTree.t()
        ]) ::
          BinTree.t()
  @doc ~S"""
  Apply a beta rules from tableaux to all the leaf nodes of a tree.
  """

  def add_beta_rules(nil, _, _, _, _, _), do: nil

  def add_beta_rules(
        %BinTree{nid: nid, left: nil, right: nil} = tree,
        %TableauxNode{sign: lsign, expression: lexp, string: lstr, nid: lnid, source: lsource},
        %TableauxNode{sign: rsign, expression: rexp, string: rstr, nid: rnid, source: rsource},
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
              value: lexp,
              sign: lsign,
              string: lstr,
              nid: lnid,
              source: lsource,
              closed: closes_path({lsign, lstr}, [tree | path])
            },
            right: %BinTree{
              value: rexp,
              sign: rsign,
              string: rstr,
              nid: rnid,
              source: rsource,
              closed: closes_path({rsign, rstr}, [tree | path])
            }
        }

      false ->
        if is_closed_path do
          %BinTree{tree | closed: true}
        else
          tree
        end
    end
  end

  def add_beta_rules(
        %BinTree{nid: nid, left: left, right: right} = tree,
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
          closed: true
      }
    else
      %BinTree{
        tree
        | left:
            add_beta_rules(left, lexp, rexp, ancestor, ancestor_found || nid == ancestor, [
              tree | path
            ]),
          right:
            add_beta_rules(right, lexp, rexp, ancestor, ancestor_found || nid == ancestor, [
              tree | path
            ])
      }
    end
  end
end
