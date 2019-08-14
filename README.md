# Py2Call.jl

Call both Python 2 and Python 3 from a single Julia session. 

### Install

```julia
] add https://github.com/marius311/Py2Call.git
```

### Usage

Assuming your main PyCall is built with Python 3, 

```julia
julia> using PyCall

julia> using Py2Call
      From worker 2:	  Building Conda ─→ `~/.julia/packages/Conda/kLXeC/deps/build.log`
      From worker 2:	  Building PyCall → `~/.julia/packages/PyCall/ttONZ/deps/build.log`
      From worker 2:	  Building Conda ─→ `~/.julia/packages/Conda/kLXeC/deps/build.log`
      From worker 2:	  Building PyCall → `~/.julia/packages/PyCall/ttONZ/deps/build.log`

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

**Notes:** This will trigger two rebuilds and recompiles of PyCall each time. It will also create a worker process which is linked with Python 2 (you can get its ID at `PyCall.id_py2worker`). Exclude this worker from parallel jobs if the parallel jobs require a linked Python 3.
