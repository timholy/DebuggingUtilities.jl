using DebuggingUtilities
using Base.Test

io = IOBuffer()
DebuggingUtilities.showlnio[] = io

function foo()
    x = 5
    @showln x
    x = 7
    @showln x
    nothing
end

foo()

str = chomp(takebuf_string(io))
target = ("x = 5", "(in foo at", "x = 7", "(in foo at")
for (i,ln) in enumerate(split(str, '\n'))
    ln = lstrip(ln)
    @test startswith(ln, target[i])
end

DebuggingUtilities.showlnio[] = STDOUT
nothing

# Just make sure these run
test_showline("noerror.jl")
@test_throws DomainError test_showline("error.jl")
time_showline("noerror.jl")
