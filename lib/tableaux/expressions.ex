defmodule Expressions do
  @type expr ::
          atom
          | {:negation, atom | expr()}
          | {:conjunction, atom | expr(), atom | expr()}
          | {:disjunction, atom | expr(), atom | expr()}
          | {:implication, atom | expr(), atom | expr()}

  @spec to_string_representation(expr()) :: binary
  def to_string_representation(atom) when is_atom(atom) do
    "#{atom}"
  end

  def to_string_representation({:negation, negated}) when is_atom(negated) do
    "¬#{to_string_representation(negated)}"
  end

  def to_string_representation({:negation, negated}) do
    "¬(#{to_string_representation(negated)})"
  end

  def to_string_representation({:conjunction, left, right})
      when is_atom(left) and is_atom(right) do
    "#{to_string_representation(left)}∧#{to_string_representation(right)}"
  end

  def to_string_representation({:conjunction, left, right}) when is_atom(left) do
    "#{to_string_representation(left)}∧(#{to_string_representation(right)})"
  end

  def to_string_representation({:conjunction, left, right}) when is_atom(right) do
    "(#{to_string_representation(left)})∧#{to_string_representation(right)}"
  end

  def to_string_representation({:conjunction, left, right}) do
    "(#{to_string_representation(left)})∧(#{to_string_representation(right)})"
  end

  def to_string_representation({:disjunction, left, right})
      when is_atom(left) and is_atom(right) do
    "#{to_string_representation(left)}∨#{to_string_representation(right)}"
  end

  def to_string_representation({:disjunction, left, right}) when is_atom(left) do
    "#{to_string_representation(left)}∨(#{to_string_representation(right)})"
  end

  def to_string_representation({:disjunction, left, right}) when is_atom(right) do
    "(#{to_string_representation(left)})∨#{to_string_representation(right)}"
  end

  def to_string_representation({:disjunction, left, right}) do
    "(#{to_string_representation(left)})∨(#{to_string_representation(right)})"
  end

  def to_string_representation({:implication, left, right})
      when is_atom(left) and is_atom(right) do
    "#{to_string_representation(left)}→#{to_string_representation(right)}"
  end

  def to_string_representation({:implication, left, right}) when is_atom(left) do
    "#{to_string_representation(left)}→(#{to_string_representation(right)})"
  end

  def to_string_representation({:implication, left, right}) when is_atom(right) do
    "(#{to_string_representation(left)})→#{to_string_representation(right)}"
  end

  def to_string_representation({:implication, left, right}) do
    "(#{to_string_representation(left)})→(#{to_string_representation(right)})"
  end

  def to_simple_propositions(nil) do
    []
  end

  def to_simple_propositions(atom) when is_atom(atom) do
    [atom]
  end

  def to_simple_propositions({:negation, negated}) when is_atom(negated) do
    [negated]
  end

  def to_simple_propositions({:negation, negated}) do
    to_simple_propositions(negated)
  end

  def to_simple_propositions({_, left, right}) do
    [to_simple_propositions(left), to_simple_propositions(right)]
    |> Enum.flat_map(& &1)
  end
end
