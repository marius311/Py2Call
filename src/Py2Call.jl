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
    
    # make the worker's LOAD_PATH start with Py2Call/Project.toml, which is
    # where we specify the custom version of PyCall
    OLD_JULIA_LOAD_PATH = get(ENV,"JULIA_LOAD_PATH",nothing)
    ENV["JULIA_LOAD_PATH"] = join([abspath(joinpath(dirname(@__FILE__),"..")); Base.load_path()],":")
    
    id_py2worker[] = addprocs(1, restrict=true)[1]
    
    if OLD_JULIA_LOAD_PATH == nothing
        delete!(ENV,"JULIA_LOAD_PATH")
    else
        ENV["JULIA_LOAD_PATH"] = OLD_JULIA_LOAD_PATH
    end
    
end

macro py2_str(str)
    py_str_ex = esc(macroexpand(__module__, :($__module__.Py2Call.@py_str $str)))
    :(@fetchfrom $(id_py2worker[]) $py_str_ex)
end

end
