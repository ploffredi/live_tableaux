defmodule TableauxTest do
  use ExUnit.Case, async: true

  doctest Tableaux

  test "complex tableaux formula" do
      assert TableauxSimplified.is_valid?("|-((((((( ¬ n) ∨ ( ¬ q)) ∨ ((n) ∧ (u))) ∨ ((( ¬ w) ∧ ( ¬ p)) ∨ ((m) → (s)))) ∧ (((( ¬ w) ∨ (e)) ∧ (( ¬ w) ∨ (w))) → ((( ¬ f) ∧ (g)) → (( ¬ o) → ( ¬ x))))) → (((((b) ∨ (m)) ∨ ((l) → ( ¬ i))) ∨ ( ¬ z)) ∧ (((( ¬ h) ∧ ( ¬ n)) ∧ (( ¬ j) ∧ ( ¬ p))) ∨ (((v) ∨ (d)) ∧ ((a) ∨ ( ¬ e)))))) ∧ ((((((r) ∧ (o)) → ((v) ∨ (m))) ∧ ((( ¬ b) → ( ¬ g)) ∨ (( ¬ k) → ( ¬ z)))) ∧ (((( ¬ u) ∨ (o)) → ((k) → ( ¬ p))) → (((n) → (f)) ∧ ((i) ∨ ( ¬ r))))) ∨ (((((d) ∨ ( ¬ e)) ∨ (h)) ∨ ((( ¬ c) → ( ¬ k)) → ((a) ∧ ( ¬ w)))) ∧ (((( ¬ o) ∨ (u)) ∨ ((o) → (g))) → (q))))) ∨ ( ¬ ((((((( ¬ n) ∨ ( ¬ q)) ∨ ((n) ∧ (u))) ∨ ((( ¬ w) ∧ ( ¬ p)) ∨ ((m) → (s)))) ∧ (((( ¬ w) ∨ (e)) ∧ (( ¬ w) ∨ (w))) → ((( ¬ f) ∧ (g)) → (( ¬ o) → ( ¬ x))))) → (((((b) ∨ (m)) ∨ ((l) → ( ¬ i))) ∨ ( ¬ z)) ∧ (((( ¬ h) ∧ ( ¬ n)) ∧ (( ¬ j) ∧ ( ¬ p))) ∨ (((v) ∨ (d)) ∧ ((a) ∨ ( ¬ e)))))) ∧ ((((((r) ∧ (o)) → ((v) ∨ (m))) ∧ ((( ¬ b) → ( ¬ g)) ∨ (( ¬ k) → ( ¬ z)))) ∧ (((( ¬ u) ∨ (o)) → ((k) → ( ¬ p))) → (((n) → (f)) ∧ ((i) ∨ ( ¬ r))))) ∨ (((((d) ∨ ( ¬ e)) ∨ (h)) ∨ ((( ¬ c) → ( ¬ k)) → ((a) ∧ ( ¬ w)))) ∧ (((( ¬ o) ∨ (u)) ∨ ((o) → (g))) → (q))))))")==true
  end

  test "reference tableaux formula" do
    assert TableauxSimplified.is_valid?("|-(p∨(q∧r))→((p∨q)∧(p∨r))")==true
  end

  test "invalid reference tableaux formula" do
    assert TableauxSimplified.is_valid?("(p∨(q∧r))→((p∨q)∧(p∨r))|-!(p∨(q∧r))→((p∨q)∧(p∨r))")==false
  end
end
