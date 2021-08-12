Benchee.run(%{
  "TableauxSimplified Pietro PHP-3" => fn ->
    TableauxSimplified.prove(ProblemGenerator.generate(:php, 3))
  end,
  "Tableaux Tree Pietro PHP-3" => fn -> Tableaux.prove(ProblemGenerator.generate(:php, 3)) end,
  "Tableaux Luis PHP-3" => fn -> Luis.Tableaux.prove(ProblemGenerator.generate(:php, 3)) end
})
