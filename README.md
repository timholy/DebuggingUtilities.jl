# DebuggingUtilities

[![Build Status](https://travis-ci.org/timholy/DebuggingUtilities.jl.svg?branch=master)](https://travis-ci.org/timholy/DebuggingUtilities.jl)

This package contains simple utilities that may help debug julia code.

# Installation

Install with

```jl
Pkg.clone("https://github.com/timholy/DebuggingUtilities.jl.git")
```

# Usage

## @showln

`@showln` shows variable values and the line number at which the
statement was executed. This can be useful when variables change value
in the course of a single function. For example:

```jl
function foo()
    x = 5
    @showln x
    x = 7
    @showln x
    nothing
end
```
might produce output like
```
            x = 5
            (in foo at ./error.jl:26 at /tmp/showln_test.jl:52)
            x = 7
            (in foo at ./error.jl:26 at /tmp/showln_test.jl:54)
```
Line numbers are not typically accurate on julia-0.4, but they are with julia-0.5.

## test_showline

This is similar to `include`, except it displays progress. This can be
useful in debugging long scripts that cause, e.g., segfaults.

## time_showline

Also similar to `include`, but it also measures the execution time of
each expression, and prints them in order of increasing duration.
