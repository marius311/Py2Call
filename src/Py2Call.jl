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
    
    # don't load currently loaded packages on the worker
    Base.toplevel_load[] = false
    id_py2worker[] = addprocs(1, exeflags="--project=$(joinpath(dirname(@__FILE__),".."))", restrict=true)[1]
    Base.toplevel_load[] = true
    
    # "hide" this worker from the pool of workers so subsequently loaded
    # packages are not loaded on it either
    pop!(Distributed.PGRP.workers) 
    
    @everywhere id_py2worker[] @eval Main begin
        using Py2Call
        using PyCall
    end
    
end

macro py2_str(str)
    :(@fetchfrom id_py2worker[] @py_str $str)
end

end
