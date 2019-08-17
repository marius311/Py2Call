module Py2Call

export @py2_str

using Distributed
using PyCall
using Pkg

const id_py2worker = Ref{Int}()

function __init__()
    if myid() == 1
        init_py2_worker()
    end
end

function init_py2_worker()
    id_py2worker[] = addprocs(1, exeflags="--project=$(joinpath(dirname(@__FILE__),".."))", restrict=true)[1]
    @everywhere id_py2worker[] @eval Main using PyCall
end

macro py2_str(str)
    :(@fetchfrom id_py2worker[] @py_str $str)
end

end
