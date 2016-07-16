Nonterminals
  program statements definition new_word
  capture capture_list capture_name
  commands command block.
Terminals
  int float word string
  start_block end_block
  start_def end_def
  start_capture end_capture
  end_program.
Rootsymbol
  program.

program -> statements             : '$1'.
program -> statements end_program : '$1'.

statements -> command                : ['$1'].
statements -> command statements     : ['$1'|'$2'].
statements -> definition             : ['$1'].
statements -> definition statements  : ['$1'|'$2'].

definition -> start_def new_word commands end_def : {def, '$2', {block, no_capture, '$3'}}.
definition -> start_def new_word capture commands end_def : {def, '$2', {block, '$3', '$4'}}.

capture -> start_capture capture_list end_capture : '$2'.
capture -> start_capture end_capture : no_capture.

capture_list -> capture_name              : ['$1'].
capture_list -> capture_name capture_list : ['$1'|'$2'].

commands -> command           : ['$1'].
commands -> command commands  : ['$1'|'$2'].

command -> word   : extract_word('$1').
command -> int    : extract_literal('$1').
command -> float  : extract_literal('$1').
command -> string : extract_literal('$1').
command -> block  : '$1'.

new_word -> word      : extract_new_word('$1').
capture_name -> word  : extract_new_word('$1').

block -> start_block end_block : {block, no_capture, []}.
block -> start_block commands end_block : {block, no_capture, '$2'}.
block -> start_block capture commands end_block : {block, '$2', '$3'}.

Erlang code.

extract_word({_, _, Value}) -> Value.
extract_new_word({_, _, {word, Value}}) -> Value.
extract_literal({_, _, Value}) -> Value.
