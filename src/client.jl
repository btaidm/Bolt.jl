struct BoltClient
	session::BoltSession
end

function BoltClient(socket::IO, versions::NTuple{N,BoltVersion} = (LatestVersion(),BoltVersion(0),BoltVersion(0),VersionOne())) where {N}
	@assert 0 < N <= 4
	if N < 4
		versions = (versions...,(BoltVersion(0) for i in 1:(4-1-length(versions)))..., VersionOne)
	end

	const MAGICK_BYTES = (0x60,0x60,0xB0,0x17)
	write(socket,Ref(MAGICK_BYTES))
	write(socket,versions)

	selectedVersion = Int(ntoh(read(socket,UInt32)))
	selectedVersion == 0 && throw(VersionException())
	
	return BoltClient(BoltSession(socket, version = selectedVersion))
end

# Connect Functions

Sockets.connect(::Type{BoltClient}, args...; versions = (LatestVersion(),BoltVersion(0),BoltVersion(0),VersionOne())) where {N} = BoltClient(connect(args...),versions)

# Close Functions
Base.close(c::BoltClient) = close(c.session.socket)