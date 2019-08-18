# Py2Call.jl

Call both Python 2 and Python 3 from a single Julia session. 

### Install

```julia
julia> ENV["PYTHON"] = "/path/to/python"
julia> ENV["PYTHON2"] = "/path/to/python2"
pkg> add https://github.com/marius311/Py2Call.git
```

### Usage

```julia
julia> using PyCall

julia> using Py2Call

julia> py"""
       import sys
       """

julia> py2"""
       import sys
       """

julia> py"sys.version"
"3.7.3 (default, Apr  4 2019, 23:33:31) \n[GCC 7.3.0]"

julia> py2"sys.version"
"2.7.16 (default, Apr  6 2019, 01:42:57) \n[GCC 8.3.0]"
```

You can always reset the Python versions used,

```bash
PYTHON=/path/to/python PYTHON2=/path/to/python2 julia -e 'using Pkg; Pkg.build("Py2Call")'
```

If you only use Python 2 from your script, you can do `using Py2Call: @py_str` and then use `py"..."` which is more succinct and may be syntax highlighted depending on editor, but will call Python 2.

### How it works

Building this package installs an older version of PyCall (1.91.1) into it's own environment and builds it for Python 2, while the version of PyCall in your main environment stays built for Python 3 (note, this means you can't use this same old PyCall version in your main environment). 

The Py2Call package then spawns a worker process which is running in the other environment, and `py2"..."` simply forwards to `py"..."` to the worker. Note two consequences of this extra worker: 1) All `using Foo` statements after you load `Py2Call` will load `Foo` on the remote worker as well, and thus take longer; put `using Py2Call` at the end of your imports to remedy this 2) If you run parallel jobs using all workers, one of the workers will be the Python 2 worker. If this is undesired, exclude it; you can get its worker ID with `Py2Call.id_py2worker[]`.
