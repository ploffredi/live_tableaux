defmodule Expressions do
  @type expr ::
          atom
          | {:negation, atom | expr()}
          | {:conjunction, atom | expr(), atom | expr()}
          | {:disjunction, atom | expr(), atom | expr()}
          | {:implication, atom | expr(), atom | expr()}

  @spec expression_to_string(expr()) :: binary
  def expression_to_string(atom) when is_atom(atom) do
    "#{atom}"
  end

  def expression_to_string({:negation, negated}) when is_atom(negated) do
    "¬#{expression_to_string(negated)}"
  end

  def expression_to_string({:negation, negated}) do
    "¬(#{expression_to_string(negated)})"
  end

  def expression_to_string({:conjunction, left, right}) when is_atom(left) and is_atom(right) do
    "#{expression_to_string(left)}∧#{expression_to_string(right)}"
  end

  def expression_to_string({:conjunction, left, right}) when is_atom(left) do
    "#{expression_to_string(left)}∧(#{expression_to_string(right)})"
  end

  def expression_to_string({:conjunction, left, right}) when is_atom(right) do
    "(#{expression_to_string(left)})∧#{expression_to_string(right)}"
  end

  def expression_to_string({:conjunction, left, right}) do
    "(#{expression_to_string(left)})∧(#{expression_to_string(right)})"
  end

  def expression_to_string({:disjunction, left, right}) when is_atom(left) and is_atom(right) do
    "#{expression_to_string(left)}∨#{expression_to_string(right)}"
  end

  def expression_to_string({:disjunction, left, right}) when is_atom(left) do
    "#{expression_to_string(left)}∨(#{expression_to_string(right)})"
  end

  def expression_to_string({:disjunction, left, right}) when is_atom(right) do
    "(#{expression_to_string(left)})∨#{expression_to_string(right)}"
  end

  def expression_to_string({:disjunction, left, right}) do
    "(#{expression_to_string(left)})∨(#{expression_to_string(right)})"
  end

  def expression_to_string({:implication, left, right}) when is_atom(left) and is_atom(right) do
    "#{expression_to_string(left)}→#{expression_to_string(right)}"
  end

  def expression_to_string({:implication, left, right}) when is_atom(left) do
    "#{expression_to_string(left)}→(#{expression_to_string(right)})"
  end

  def expression_to_string({:implication, left, right}) when is_atom(right) do
    "(#{expression_to_string(left)})→#{expression_to_string(right)}"
  end

  def expression_to_string({:implication, left, right}) do
    "(#{expression_to_string(left)})→(#{expression_to_string(right)})"
  end

  def expression_to_atom_list(nil) do
    []
  end

  def expression_to_atom_list(atom) when is_atom(atom) do
    [atom]
  end

  def expression_to_atom_list({:negation, negated}) when is_atom(negated) do
    [negated]
  end

  def expression_to_atom_list({:negation, negated}) do
    expression_to_atom_list(negated)
  end

  def expression_to_atom_list({_, left, right}) do
    [expression_to_atom_list(left), expression_to_atom_list(right)]
    |> Enum.flat_map(& &1)
  end
end
