__precompile__()

module SONames

const SONAMES = Ref(Dict{String,String}())

"""
    SONames.read()

Reload a mapping of system shared libraries, with keys as names of the form `libXX` and
values as the fully qualified paths of the form `/path/to/libXX.so.ver`.
Full paths can then be looked up with `SONames.lookup("libXX")`.
"""
function read()
    global SONAMES
    empty!(SONAMES[])
    @static if Sys.islinux()
        cmd = `/sbin/ldconfig -p`
    else
        cmd = `/sbin/ldconfig -r`
    end
    for (n, line) in enumerate(eachline(cmd, keep=false))
        # The first two lines aren't relevant
        n > 2 || continue
        @static if Sys.islinux()
            # Idk, I'm writing this on FreeBSD
        else
            inds = findfirst(":-l", line)
            inds === nothing && continue
            dotind = findnext(==('.'), line, last(inds))
            dotind === nothing && continue
            spc = findlast(==(' '), line)
            spc === nothing && continue

            name = string("lib", line[nextind(line, last(inds)):prevind(line, dotind)])
            sopath = line[nextind(line, spc):end]
        end
        push!(SONAMES[], name => sopath)
    end
    return
end

"""
    SONames.lookup(lib)

Look up the fully qualified path for the given shared library name.

# Examples
```julia-repl
julia> SONames.lookup("libc")
"/lib/libc.so.7"
```
"""
lookup(lib::AbstractString) = (global SONAMES; get(SONAMES[], lib, ""))

function __init__()
    if !Sys.islinux() && Sys.KERNEL !== :FreeBSD
        error("SO name mapping is only available on Linux and FreeBSD")
    end
    read()
end

end # module
