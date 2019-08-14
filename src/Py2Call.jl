module Py2Call

export @py2_str

using Distributed
using PyCall
using Pkg


function __init__()
    
    if myid() == 1
        
        global id_py2worker = addprocs(1, restrict=true)[1]

        @everywhere id_py2worker @eval begin
            ENV["PYTHON"] = $(get(ENV,"PYTHON2","python2"))
            using Pkg
            Pkg.build("PyCall")
            using PyCall
        end
        
        # then rebuild PyCall back to the original version (the py2worker has
        # already loaded Python 2, so that will stick)
        @eval @everywhere id_py2worker begin
            ENV["PYTHON"] = $(PyCall.python)
            Pkg.build("PyCall")
        end
    end
    
end

macro py2_str(str)
    :(@fetchfrom id_py2worker @py_str $str)
end

end
