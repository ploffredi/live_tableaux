Nonterminals formula.
Terminals '(' ')' atom 'and' 'or' 'not' 'implies'.
Rootsymbol formula.

Left 100 'implies'.
Left 200 'and'.
Left 200 'or'.
Unary 300 'not'.

formula  -> atom                      : value('$1').
formula  -> '(' formula ')'           : '$2'.
formula  -> 'not' formula             : {value('$1'), '$2'}.
formula  -> formula 'and' formula     : {value('$2'), '$1', '$3'}.
formula  -> formula 'or' formula      : {value('$2'), '$1', '$3'}.
formula  -> formula 'implies' formula : {value('$2'), '$1', '$3'}.

Erlang code.

value({_Token, _Line, Value}) -> Value;
value({Value, _Line}) -> Value.
