module Py2Call

export @py2_str

using Distributed
using Pkg
import PyCall

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
    
    # launch worker
    id_py2worker[] = addprocs(1, restrict=true)[1]
    
    # reset original JULIA_LOAD_PATH
    if OLD_JULIA_LOAD_PATH == nothing
        delete!(ENV,"JULIA_LOAD_PATH")
    else
        ENV["JULIA_LOAD_PATH"] = OLD_JULIA_LOAD_PATH
    end
    
    @everywhere id_py2worker[] @eval Main import PyCall
    
end

for macro_name in (:py_str, :py2_str)
    @eval macro $macro_name(str,scope="l")
        py_str_ex = quote
            try
                $(@__MODULE__).PyCall.@py_str $str
            catch err
                err isa Main.PyCall.PyError ? error(err.val) : rethrow()
            end
        end
        exs = [:(@fetchfrom $(id_py2worker[]) $(esc(macroexpand((s=='l' ? __module__ : Main),py_str_ex)))) for s in scope]
        :(begin $(exs...) end)
    end
end


end
