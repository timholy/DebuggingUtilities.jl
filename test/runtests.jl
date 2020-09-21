using DebuggingUtilities
using Test

include("funcdefs.jl")
funcdefs_path = joinpath(@__DIR__, "funcdefs.jl")

@testset "DebuggingUtilities" begin
    io = IOBuffer()
    DebuggingUtilities.showlnio[] = io

    @test foo() == 7

    str = chomp(String(take!(io)))
    target = ("x = 5", "(in $funcdefs_path:4)", "x = 7", "(in $funcdefs_path:6)")
    for (i,ln) in enumerate(split(str, '\n'))
        ln = lstrip(ln)
        @test ln == target[i]
    end

    @test recurses(1) == 10
    str = chomp(String(take!(io)))
    lines = split(str, '\n')
    offset = lstrip(lines[1]).offset
    for i = 1:5
        j = 2*i-1
        k = 4*i-3
        ln = String(lines[k])
        lns = lstrip(ln)
        @test lns.offset == offset + i - 1
        @test lns == "n = $j"
        ln = String(lines[k+1])
        lns = lstrip(ln)
        @test lns.offset == offset + i - 1
        @test lns == "(in recurses at $funcdefs_path:10)"
        j += 1
        ln = String(lines[k+2])
        lns = lstrip(ln)
        @test lns.offset == offset + i - 1
        @test lns == "n = $j"
        ln = String(lines[k+3])
        lns = lstrip(ln)
        @test lns.offset == offset + i - 1
        @test lns == "(in recurses at $funcdefs_path:12)"
    end

    # Just make sure these run
    io = IOBuffer()
    DebuggingUtilities.showlnio[] = io
    test_showline("noerror.jl")
    @test_throws DomainError test_showline("error.jl")
    time_showline("noerror.jl")

    DebuggingUtilities.showlnio[] = stdout
end
