{ For parsing tests }

: FIZZBUZZ { n }
  (/ 15 0 =) ("fizzbuzz" PRINT)
  (/ 5 0 =) ("fizz" PRINT)
  (/ 3 0 =) ("buzz" PRINT)
  (PRINT)
  CASE
;

100 FIZZBUZZ
99 FIZZBUZZ
98 FIZZBUZZ
