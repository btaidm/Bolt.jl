module Bolt

using Sockets

import Base: close
import Sockets: connect


export VersionException
export BoltVersion,BoltClient,BoltSession


# Errors

struct VersionException <: Exception end

# Version Info

struct BoltVersion{V}
	function BoltVersion{V}() where {V}
		@assert V isa Int && V >= 0
		new()
	end
end

BoltVersion(v::Integer) = BoltVersion{Int(v)}()

Base.write(io::IO, ::BoltVersion{V}) where {V} = write(io,hton(UInt32(V)))
Base.write(io::IO, versions::NTuple{4,BoltVersion}) = foreach(v->write(io,v),versions)

const LatestVersion = BoltVersion{1}
const VersionOne = BoltVersion{1}

struct BoltSession{V <: BoltVersion}
	socket::IO
end

BoltSession(socket::IO; version::Int = 1) = BoltSession{BoltVersion{version}}(socket)


include("protocol/v1.jl")
using .V1


include("client.jl")
include("server.jl")

end # module
