VARIABLE x
VARIABLE y

10 x !
20 y !

x @ y @ + .
x @ y @ - .
x @ y @ * .
x @ y @ / .
x @ y @ MOD .
x @ y @ /MOD .

x @ y @ = .
x @ y @ <> .
x @ y @ < .
x @ y @ > .
x @ y @ <= .
x @ y @ >= .

5 3 AND .
5 3 OR .
5 INVERT .
5 ABS .
5 NEGATE .

x @ y @ < IF
    100 x !
ELSE
    200 y !
THEN

BEGIN
    x @ 1 - x !
    x @ 0 >
REPEAT
