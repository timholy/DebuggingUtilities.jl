module DebuggingUtilities

export @showln, @showlnt, test_showline, time_showline

"""
DebuggingUtilities contains a few tools that may help debug julia code. The
exported tools are:

- `@showln`: like `@show`, but displays file and line number information as well
- `@showlnt`: like `@showlnt`, but also uses indentation to display recursion depth
- `test_showline`: a function that displays progress as it executes a file
- `time_showline`: a function that displays execution time for each expression in a file
"""
DebuggingUtilities

## @showln and @showlnt

mutable struct FlushedIO <: IO
    io
end

function Base.println(io::FlushedIO, args...)
    println(io.io, args...)
    flush(io.io)
end
Base.getindex(io::FlushedIO) = io.io
Base.setindex!(io::FlushedIO, newio) = io.io = newio

const showlnio = FlushedIO(stdout)

"""
`@showln x` prints "x = val", where `val` is the value of `x`, along
with information about the function, file, and line number at which
this statement was executed. For example:

```julia
function foo()
    x = 5
    @showln x
    x = 7
    @showln x
    nothing
end
```

might produce output like

    x = 5
    (in foo at ./error.jl:26 at /tmp/showln_test.jl:52)
    x = 7
    (in foo at ./error.jl:26 at /tmp/showln_test.jl:54)

If you need call depth information, see [`@showlnt`](@ref).
"""
macro showln(exs...)
    blk = showexprs(exs)
    blk = quote
        local indent = 0
        $blk
        println(showlnio[], "(in ", $(string(__source__.file)), ':', $(__source__.line), ')')
    end
    if !isempty(exs)
        push!(blk.args, :value)
    end
    blk
end

"""
`@showlnt x` prints "x = val", where `val` is the value of `x`, along
with information about the function, file, and line number at which
this statement was executed, using indentation to indicate recursion depth.
For example:

```julia
function recurses(n)
    @showlnt n
    n += 1
    @showlnt n
    if n < 10
        n = recurses(n)
    end
    return n
end
```

might produce output like

            x = 5
            (in foo at ./error.jl:26 at /tmp/showln_test.jl:52)
            x = 7
            (in foo at ./error.jl:26 at /tmp/showln_test.jl:54)

This macro causes a backtrace to be taken, and looking up the
corresponding code information is relatively expensive, so using
`@showlnt` can have a substantial performance cost.

The indentation of the line is proportional to the length of the
backtrace, and consequently is an indication of recursion depth.
"""
macro showlnt(exs...)
    blk = showexprs(exs)
    blk = quote
        local bt = backtrace()
        local indent = length(bt)  # to mark recursion
        $blk
        print(showlnio[], " "^indent*"(")
        show_backtrace1(showlnio[], bt)
        println(showlnio[], ")")
    end
    if !isempty(exs)
        push!(blk.args, :value)
    end
    blk
end

function showexprs(exs)
    blk = Expr(:block)
    for ex in exs
        push!(blk.args, :(println(showlnio[], " "^indent, sprint(Base.show_unquoted,$(Expr(:quote, ex)),indent)*" = ", repr(begin value=$(esc(ex)) end))))
    end
    blk
end

# backtrace utilities

function print_btinfo(io, frm)
    print(io, "in ", frm.func, " at ", frm.file, ":", frm.line)
end
function show_backtrace1(io, bt)
    st = stacktrace(bt)
    for frm in st
        funcname = frm.func
        if funcname != :backtrace && funcname != Symbol("macro expansion")
            print_btinfo(io, frm)
            break
        end
    end
end

"""
`test_showline(filename)` is equivalent to `include(filename)`, except
that it also displays the expression and file-offset (in characters) for
each expression it executes. This can be useful for debugging errors,
especially those that cause a segfault.
"""
function test_showline(filename)
    str = read(filename, String)
    Core.eval(Main, Meta.parse("using Test"))
    idx = 1
    while idx < length(str)
        ex, idx = Meta.parse(str, idx)
        try
            println(showlnio, idx, ": ", ex)
        catch
            println(showlnio, "failed to print line starting at file-offset ", idx)
        end
        Core.eval(Main,ex)
    end
    println(showlnio, "done")
end

"""
`time_showline(filename)` is equivalent to `include(filename)`, except
that it also analyzes the time expended on each expression within the
file. Once finished, it displays the file-offset (in characters),
elapsed time, and expression in order of increasing duration.  This
can help you identify bottlenecks in execution.

This is less useful now that julia has package precompilation, but can
still be handy on occasion.
"""
function time_showline(filename)
    str = read(filename, String)
    idx = 1
    exprs = Any[]
    t = Float64[]
    pos = Int[]
    while idx < length(str)
        ex, idx = Meta.parse(str, idx)
        push!(exprs, ex)
        push!(t, @elapsed Core.eval(Main,ex))
        push!(pos, idx)
    end
    perm = sortperm(t)
    for p in perm
        print(showlnio[], pos[p], " ", t[p], ": ")
        str = string(exprs[p])
        println(showlnio[], split(str, '\n')[1])
    end
    println(showlnio[], "done")
end

function __init__()
    showlnio[] = stdout
end

end # module
