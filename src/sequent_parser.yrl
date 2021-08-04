Nonterminals sequent elems neg ascendants ascendant descendant.
Terminals  '(' ')' separator assertion conjunction disjunction implication negation atom.
Rootsymbol sequent.  

Left 50 assertion.
Left 100 implication.
Left 200 disjunction.
Left 300 conjunction.
Unary 400 negation.

%<expr> :== <term> {<or> <term>}
%<term> :== <factor> {<and> <factor>}
%<factor> :== <not> <factor> | "(" <expr> ")" | <const>
%<const> :== "true" | "false"




elems -> neg : '$1'.
elems -> elems conjunction elems : {extract_token('$2'), '$1' , '$3'}.
elems -> elems disjunction elems : {extract_token('$2'), '$1' , '$3'}.
elems -> elems implication elems : {extract_token('$2'), '$1' , '$3'}.
elems -> '(' elems ')' : '$2'.
elems -> atom : extract_token('$1').  


sequent -> assertion descendant : '$2'.
sequent -> ascendants assertion descendant : map_index('$1' ++ '$3',1).


descendant -> elems : ['Elixir.TableauxNode':'__struct__'(#{expression => '$1', step => 0, source => 0, sign => 'F', string => 'Elixir.Expressions':expression_to_string('$1')})].

ascendants -> ascendant : ['$1'].
ascendants -> ascendant separator ascendants : ['$1'|'$3'].
ascendant -> elems : 'Elixir.TableauxNode':'__struct__'(#{expression => '$1', step => 0, source => 0, sign => 'T', string => 'Elixir.Expressions':expression_to_string('$1')}).

neg -> negation elems :  {extract_token('$1'), '$2'}.   


Erlang code.

extract_token({_Token, _Line, Value}) -> Value.


map_index(Nodes, Idx) -> 
  case Nodes of
    [] ->
      none;
    [H] ->
      [with_index(H, Idx)];
    [H | T] ->  %% Switched
      [with_index(H, Idx)|map_index(T, Idx + 1)]
  end.

with_index(Node, Idx) -> maps:update('nid', Idx, Node).