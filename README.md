# DebuggingUtilities

[![Build Status](https://travis-ci.org/timholy/DebuggingUtilities.jl.svg?branch=master)](https://travis-ci.org/timholy/DebuggingUtilities.jl)

This package contains simple utilities that may help debug julia code.

# Installation

Install with

```julia
pkg> dev https://github.com/timholy/DebuggingUtilities.jl.git
```

When you use it in packages, you should `activate` the project and add
DebuggingUtilities as a dependency use `project> dev DebuggingUtilities`.

# Usage

## @showln

`@showln` shows variable values and the line number at which the
statement was executed. This can be useful when variables change value
in the course of a single function. For example:

```julia
using DebuggingUtilities

function foo()
    x = 5
    @showln x
    x = 7
    @showln x
    nothing
end
```

might, when called (`foo()`), produce output like

```
x = 5
(in /home/tim/.julia/dev/DebuggingUtilities/test/funcdefs.jl:5)
x = 7
(in /home/tim/.julia/dev/DebuggingUtilities/test/funcdefs.jl:7)
7
```

## @showlnt

`@showlnt` is for recursion, and uses indentation to show nesting depth.
For example,

```julia
function recurses(n)
    @showlnt n
    n += 1
    @showlnt n
    if n < 10
        n = recurses(n+1)
    end
    return n
end
```

might, when called as `recurses(1)`, generate

```
                                 n = 1
                                 (in recurses at /home/tim/.julia/dev/DebuggingUtilities/test/funcdefs.jl:10)
                                 n = 2
                                 (in recurses at /home/tim/.julia/dev/DebuggingUtilities/test/funcdefs.jl:12)
                                  n = 3
                                  (in recurses at /home/tim/.julia/dev/DebuggingUtilities/test/funcdefs.jl:10)
                                  n = 4
                                  (in recurses at /home/tim/.julia/dev/DebuggingUtilities/test/funcdefs.jl:12)
                                   n = 5
                                   (in recurses at /home/tim/.julia/dev/DebuggingUtilities/test/funcdefs.jl:10)
                                   n = 6
                                   (in recurses at /home/tim/.julia/dev/DebuggingUtilities/test/funcdefs.jl:12)
                                    n = 7
                                    (in recurses at /home/tim/.julia/dev/DebuggingUtilities/test/funcdefs.jl:10)
                                    n = 8
                                    (in recurses at /home/tim/.julia/dev/DebuggingUtilities/test/funcdefs.jl:12)
                                     n = 9
                                     (in recurses at /home/tim/.julia/dev/DebuggingUtilities/test/funcdefs.jl:10)
                                     n = 10
                                     (in recurses at /home/tim/.julia/dev/DebuggingUtilities/test/funcdefs.jl:12)
```

Each additional space indicates one additional layer in the call chain.
Most of the initial space (even for `n=1`) is due to Julia's own REPL.

## test_showline

This is similar to `include`, except it displays progress. This can be
useful in debugging long scripts that cause, e.g., segfaults.

## time_showline

Also similar to `include`, but it also measures the execution time of
each expression, and prints them in order of increasing duration.
