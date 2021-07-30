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
    "(#{expression_to_string(left)}∧#{expression_to_string(right)})"
  end

  def expression_to_string({:disjunction, left, right}) when is_atom(left) and is_atom(right) do
    "#{expression_to_string(left)}∨#{expression_to_string(right)}"
  end

  def expression_to_string({:disjunction, left, right}) when is_atom(left) do
    "#{expression_to_string(left)}∨(#{expression_to_string(right)})"
  end

  def expression_to_string({:disjunction, left, right}) when is_atom(right) do
    "(#{expression_to_string(left)}∨#{expression_to_string(right)})"
  end

  def expression_to_string({:implication, left, right}) when is_atom(left) do
    "#{expression_to_string(left)}→(#{expression_to_string(right)})"
  end

  def expression_to_string({:implication, left, right}) when is_atom(left) and is_atom(right) do
    "#{expression_to_string(left)}→#{expression_to_string(right)}"
  end

  def expression_to_string({:implication, left, right}) when is_atom(right) do
    "(#{expression_to_string(left)}→#{expression_to_string(right)})"
  end

  def expression_to_string({:conjunction, left, right}) do
    "(#{expression_to_string(left)}∧#{expression_to_string(right)})"
  end

  def expression_to_string({:disjunction, left, right}) do
    "(#{expression_to_string(left)}∨#{expression_to_string(right)})"
  end

  def expression_to_string({:implication, left, right}) do
    "(#{expression_to_string(left)}→#{expression_to_string(right)})"
  end
end
