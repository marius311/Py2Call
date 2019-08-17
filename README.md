# Py2Call.jl

Call both Python 2 and Python 3 from a single Julia session. 

### Install

```julia
julia> ENV["PYTHON2"] = "/path/to/python2"
pkg> add https://github.com/marius311/Py2Call.git
```

### Usage

After installing and selecting the Python 2 version as above, you can do,

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

You can always reset the Python 2 version used by Py2Call later,

```bash
PYTHON2=/path/to/python2 julia -e 'using Pkg; Pkg.build("Py2Call")'
```

### How it works

This package installs an older version of PyCall (1.91.1) into it's own environment (note, you must have a different version than 1.91.1 in your main environment, otherwise this won't work). Then, this PyCall and the PyCall in your main environment can be built to use different versions of Python. The Py2Call package then spawns a worker process which is running in the other environment, and `py2"..."` simply forwards to `py"..."` on the worker. Note: the py2 worker is hidden and is not returned in calls to `workers()`.
