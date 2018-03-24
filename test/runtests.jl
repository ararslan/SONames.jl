using SONames
using Test

@test !isempty(SONames.SONAMES[])
empty!(SONames.SONAMES[])
@test isempty(SONames.SONAMES[])
SONames.read()
@test !isempty(SONames.SONAMES[])

@test SONames.lookup("libc") == "/lib/libc.so.7"
@test SONames.lookup("libyoloswag") == ""
