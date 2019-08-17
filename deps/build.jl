using Pkg
Pkg.activate(joinpath(dirname(@__FILE__),".."))
Pkg.instantiate()
ENV["PYTHON"] = ENV["PYTHON2"]
Pkg.build("PyCall")
