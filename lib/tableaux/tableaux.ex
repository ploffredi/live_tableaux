defmodule Tableaux do
  @moduledoc """
  Documentation for `Tableaux`.
  """

  @spec add_signs(
          [
            any
          ],
          any
        ) :: [RuleNode.t(), ...]
  def add_signs([expression], step) do
    [
      %RuleNode{
        RuleNode.empty_with_nid()
        | expression: expression,
          string: Expressions.expression_to_string(expression),
          sign: :F,
          step: step
      }
    ]
  end

  def add_signs([expression | t], step) do
    [
      %RuleNode{
        RuleNode.empty_with_nid()
        | expression: expression,
          string: Expressions.expression_to_string(expression),
          sign: :T,
          step: step
      }
      | add_signs(t, step)
    ]
  end

  def verify(sequent) do
    UniqueCounter.reset()

    signed_expressions_list = SequentParser.parse(sequent) |> add_signs(0)
    first_tree = add_alpha_rules(nil, signed_expressions_list, nil, false)
    expand(first_tree, signed_expressions_list, [])
  end

  @spec expand(any, [RuleNode.t()], [RuleNode.t()]) :: BinTree.t()
  def expand(tree, [], _) do
    tree
  end

  def expand(tree, to_apply, applied) do
    [to_expand | rest] =
      to_apply
      |> Enum.sort_by(
        &TableauxRules.get_rule_type(&1.sign, &1.expression),
        &TableauxRules.compare_operators(&1, &2)
      )

    rest
    |> Enum.map(&"#{&1.sign} #{&1.string} [#{&1.source},#{&1.nid}]")
    |> IO.inspect(label: "to apply")

    IO.inspect("#{to_expand.sign} #{to_expand.string} [#{to_expand.source},#{to_expand.nid}]",
      label: "to expand"
    )

    IO.inspect(to_expand, label: "to expand")

    expansion = TableauxRules.get_rule_expansion(to_expand)

    IO.inspect(expansion, label: "rule expansion")

    case expansion.rule_type do
      :alpha ->
        add_alpha_rules(tree, expansion.expanded_nodes, to_expand.nid, false)

      :beta ->
        add_beta_rules_list(tree, expansion.expanded_nodes, to_expand.nid)

      :atom ->
        add_alpha_rules(tree, expansion.expanded_nodes, to_expand.nid, false)
    end
    |> expand(rest ++ expansion.expanded_nodes, [to_expand | applied])
  end

  @spec from_sequent(binary) :: BinTree.t()
  @doc ~S"""
  Parses the given `sequent` into a binary tree.



  """
  def from_sequent(sequent) do
    add_alpha_rules(nil, parse_sequent(sequent), nil, false)
  end

  @spec parse_sequent(binary) :: [RuleNode.t(), ...]
  def parse_sequent(sequent) do
    add_signs(SequentParser.parse(sequent), 0)
  end

  @spec add_alpha_rules(BinTree.t(), [RuleNode.t()], binary(), boolean()) :: BinTree.t()
  @doc ~S"""
  Apply an alpha rules from tableaux to all the leaf nodes of a tree. The function is useful when you
  need to create the first tree after the sequent parsing


  """
  def add_alpha_rules(nil, list, _ancestor, _ancestor_found) do
    BinTree.linear_branch_from_list(list)
  end

  def add_alpha_rules(
        %BinTree{nid: nid, left: nil, right: nil} = tree,
        list,
        ancestor,
        ancestor_found
      ) do
    case ancestor_found || nid == ancestor do
      true ->
        %BinTree{tree | left: BinTree.linear_branch_from_list(list)}

      false ->
        tree
    end
  end

  def add_alpha_rules(
        %BinTree{nid: nid, left: nil, right: right} = tree,
        list,
        ancestor,
        ancestor_found
      ) do
    %BinTree{
      tree
      | right: add_alpha_rules(right, list, ancestor, ancestor_found || nid == ancestor)
    }
  end

  def add_alpha_rules(
        %BinTree{nid: nid, left: left, right: nil} = tree,
        list,
        ancestor,
        ancestor_found
      ) do
    %BinTree{
      tree
      | left: add_alpha_rules(left, list, ancestor, ancestor_found || nid == ancestor)
    }
  end

  def add_alpha_rules(
        %BinTree{nid: nid, left: left, right: right} = tree,
        list,
        ancestor,
        ancestor_found
      ) do
    %BinTree{
      tree
      | left: add_alpha_rules(left, list, ancestor, ancestor_found || nid == ancestor),
        right: add_alpha_rules(right, list, ancestor, ancestor_found || nid == ancestor)
    }
  end

  @spec add_beta_rules_list(BinTree.t(), [nil | RuleNode.t()], binary()) :: BinTree.t()
  defp add_beta_rules_list(tree, [left, right], ancestor) do
    add_beta_rules(tree, left, right, ancestor, false)
  end

  @spec add_beta_rules(BinTree.t(), nil | RuleNode.t(), nil | RuleNode.t(), binary(), boolean()) ::
          BinTree.t()
  @doc ~S"""
  Apply a beta rules from tableaux to all the leaf nodes of a tree.
  """
  def add_beta_rules(
        %BinTree{nid: nid, left: nil, right: nil} = tree,
        %RuleNode{sign: lsign, expression: lexp, string: lstr, nid: lnid, source: lsource},
        %RuleNode{sign: rsign, expression: rexp, string: rstr, nid: rnid, source: rsource},
        ancestor,
        ancestor_found
      ) do
    case ancestor_found || ancestor == nid do
      true ->
        %BinTree{
          tree
          | left: %BinTree{
              value: lexp,
              sign: lsign,
              string: lstr,
              nid: lnid,
              source: lsource
            },
            right: %BinTree{
              value: rexp,
              sign: rsign,
              string: rstr,
              nid: rnid,
              source: rsource
            }
        }

      false ->
        tree
    end
  end

  def add_beta_rules(
        %BinTree{nid: nid, left: nil, right: right} = tree,
        lexp,
        rexp,
        ancestor,
        ancestor_found
      ) do
    %BinTree{
      tree
      | right: add_beta_rules(right, lexp, rexp, ancestor, ancestor_found || nid == ancestor)
    }
  end

  def add_beta_rules(
        %BinTree{nid: nid, left: left, right: nil} = tree,
        lexp,
        rexp,
        ancestor,
        ancestor_found
      ) do
    %BinTree{
      tree
      | left: add_beta_rules(left, lexp, rexp, ancestor, ancestor_found || nid == ancestor)
    }
  end

  def add_beta_rules(
        %BinTree{nid: nid, left: left, right: right} = tree,
        lexp,
        rexp,
        ancestor,
        ancestor_found
      ) do
    %BinTree{
      tree
      | left: add_beta_rules(left, lexp, rexp, ancestor, ancestor_found || nid == ancestor),
        right: add_beta_rules(right, lexp, rexp, ancestor, ancestor_found || nid == ancestor)
    }
  end
end
