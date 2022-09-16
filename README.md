# History.jl

A [Julia](https://www.julialang.org) package for getting REPL history
functionality similar to what [Bash](https://www.gnu.org/software/bash) provides.

## Installation

In the Julia REPL type:

```julia
] add https://github.org/GHTaarn/History.jl
```

## Use

In the Julia REPL type:

```julia
using History
```

Hereafter typing an '!' character at the beginning of a line in the Julia
REPL will activate `History` mode.

In `History` mode, a line starting with a '/' character will return the
history entries whos text contains the string on the rest of the line
(inspired by [less](https://en.wikipedia.org/wiki/Less_(Unix))
and [vi](https://www.vim.org)).
A line starting with a '^' character will return the history entries whos
text starts with the string on the rest of the line
(inspired by regular expressions).

In `History` mode, a line consisting of only an '!' character will print out
exactly enough recent REPL history to fill your screen. Any '!' characters
immediately followed by a positive integer will substitute the text from
the corresponding input line into the rest of the current line before
executing it. A negative integer after an '!' character will be substituted
with the text of the input line the given number of lines ago.

Tab completion: If the current input line contains an '!' character followed
by an integer before the cursor, then the above substitution will be performed.
In all other cases, normal julia mode tab completion will be performed.
In tab completion, `!0` can be used to refer to the current input line as it
looks when tab is pressed.

### Examples

The following examples are performed without tab completion, but using tab
completion will often avoid a lot of confusion and be more useful.

```julia-repl
julia> using History
REPL mode history initialized. Press ! to enter and backspace to exit.

History> sin(8)
0.9893582466233818

History> !-1
0.9893582466233818

History> println("!-2")
sin(8)

History> println("!-2 ")
!-1 

History> true
true

History> !!-1
false

History> println("!-1 and !-2")
!!-1 and true

History> 
```

```
History> !
10×3 Matrix{Any}:
 4315  :julia    "exit()"
 4316  :julia    "using History"
 4317  :history  "sin(8)"
 4318  :history  "!-1"
 4319  :history  "println(\"!-2\")"
 4320  :history  "println(\"!-2 \")"
 4321  :history  "true"
 4322  :history  "!!-1"
 4323  :history  "println(\"!-1 and !-2\")"
 4324  :history  "!"

History> !!4321 ? !4317 : 2*!4317
1.9787164932467636

History> ^!
3×3 Matrix{Any}:
 4318  :history  "!-1"
 4322  :history  "!!-1"
 4324  :history  "!"

History> /tln
4×3 Matrix{Any}:
 4319  :history  "println(\"!-2\")"
 4320  :history  "println(\"!-2 \")"
 4323  :history  "println(\"!-1 and !-2\")"
 4327  :history  "/tln"

History> 
```

### Exported functions

There are 4 exported functions: `history`, `histexec` `histsearch` and
`histsave`. You can
read more about these in their docstrings by typing the following in the Julia
mode REPL:

```julia
?history
?histexec
?histsearch
?histsave
```

