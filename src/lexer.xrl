Definitions.

ATOM          = [a-z1-9\_]*
WHITESPACE    = [\s\t\n\r]
AND           = \&
OR            = \|
NOT           = \!
IMPLIES       = \-\>

Rules.

{ATOM}        : {token, {atom, TokenLine, to_atom(TokenChars)}}.
\(            : {token, {'(', TokenLine}}.
\)            : {token, {')', TokenLine}}.
{AND}         : {token, {'and', TokenLine}}.
{OR}          : {token, {'or', TokenLine}}.
{NOT}         : {token, {'not', TokenLine}}.
{IMPLIES}     : {token, {'implies', TokenLine}}.
{WHITESPACE}+ : skip_token.

Erlang code.

to_atom(Chars) -> list_to_atom(Chars).
