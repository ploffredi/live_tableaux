Benchee.run(%{
  "php 3 simp" => fn -> TableauxSimplified.prove(ProblemGenerator.generate(:php, 3)) end,
  "php 3 tree" => fn -> Tableaux.is_valid?(ProblemGenerator.generate(:php, 3)) end
})
