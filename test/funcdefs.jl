# Note: tests are sensitive to the line numbers of statements below
function foo()
    x = 5
    @showln x
    x = 7
    @showln x
end

function recurses(n)
    @showlnt n
    n += 1
    @showlnt n
    if n < 10
        n = recurses(n+1)
    end
    return n
end
