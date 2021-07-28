Nonterminals elems neg.
Terminals  '(' ')' conjunction disjunction implication negation atom.
Rootsymbol elems.  

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

neg -> negation elems : {extract_token('$1'), '$2'}.   


Erlang code.

extract_token({_Token, _Line, Value}) -> Value.