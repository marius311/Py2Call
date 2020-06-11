module Py2Call

export @py2_str

using Distributed
using Pkg
using MacroTools: @capture, postwalk
import PyCall

id_py2worker = nothing

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
    global id_py2worker = addprocs(1, restrict=true)[1]
    
    # reset original JULIA_LOAD_PATH
    if OLD_JULIA_LOAD_PATH == nothing
        delete!(ENV,"JULIA_LOAD_PATH")
    else
        ENV["JULIA_LOAD_PATH"] = OLD_JULIA_LOAD_PATH
    end
    
    @everywhere id_py2worker @eval Main import PyCall
    
end

for macro_name in (:py_str, :py2_str)
    
    @eval macro $macro_name(str)
    
        # expand py"..." (in Main so PyCall uses Main's pynamespace)
        ex = macroexpand(Main, :($PyCall.@py_str $str))
        
        # a kind of hacky way to wrap the references to local variables that are
        # interpolated into the Python expression with one additional `$` since the
        # whole thing is in the end wrapped in an `@eval`
        ex = postwalk(ex) do x
            if @capture(x, $(GlobalRef(PyCall,:PyObject))(v_))
                :($(GlobalRef(PyCall,:PyObject))($(Expr(:$,v))))
            else
                x
            end
        end
        
        # ship call to worker
        ex = quote
            $Distributed.remotecall_fetch($id_py2worker) do
                try
                    result = $ex
                catch err
                    err isa $PyCall.PyError ? $error($string(err)) : $rethrow()
                end
            end
        end
        
        # wrap the whole thing in an `@eval` so that the closure we created above is
        # a closure in Main and hence can be deserialized on the py2worker without
        # it needing the caller's module loaded
        esc(Expr(:macrocall, Symbol("@eval"), @__LINE__, Main, ex))
        
    end

end


end
