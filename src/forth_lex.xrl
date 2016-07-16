Definitions.

%% A word cannot contain delimiters
NOTDELIMITERS = ^\[^\]^\(^\)^\:^\;

%% A word has to start with a non-number
NOTNUM = ^0-9

%% A word cannot have whitespace
NOTWHITESPACE = ^\s^\t^\n^\r

%% Other than these rules, anything goes
WORDCHAR  = {NOTDELIMITERS}{NOTWHITESPACE}
WORD      = [{NOTNUM}{WORDCHAR}][{WORDCHAR}]*

%% Now for everything else

%% Very basic building blocks
NUM        = [0-9]
WHITESPACE = [\s\t\n\r]

%% Actual returned tokens
INT     = {NUM}+
FLOAT   = {NUM}+\.{NUM}+((E|e)(\+|\-)?{NUM}+)?
STRING  = \".*\"
COMMENT = \{.*\}
END     = \.\.\.

Rules.

{INT}           : {token, {int, TokenLine, int_literal(TokenChars)}}.
{FLOAT}         : {token, {float, TokenLine, float_literal(TokenChars)}}.
{WORD}          : {token, {word, TokenLine, word_literal(TokenChars)}}.
{STRING}        : {token, {string, TokenLine, string_literal(TokenChars)}}.

\[              : {token, {start_block, TokenLine}}.
\]              : {token, {end_block, TokenLine}}.

\(              : {token, {start_capture, TokenLine}}.
\)              : {token, {end_capture, TokenLine}}.

\:              : {token, {start_def, TokenLine}}.
\;              : {token, {end_def, TokenLine}}.
{END}           : {end_token, {end_program, TokenLine}}.

{WHITESPACE}+   : skip_token.
{COMMENT}       : skip_token.

Erlang code.

int_literal(IntStr) ->
  list_to_integer(IntStr).

float_literal(FloatStr) ->
  list_to_float(FloatStr).

string_literal(String) ->
  Binary = 'Elixir.List':to_string(String),
  Length = byte_size(Binary),
  binary_part(Binary, 1, Length - 1).

word_literal(WordStr) ->
  Binary = 'Elixir.List':to_string(WordStr),
  Lowered = 'Elixir.String':downcase(Binary),
  {word, Lowered}.
