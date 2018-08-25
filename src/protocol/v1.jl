module V1
# V1 Types and Structs

using ..Bolt
import Base: write

abstract type Structure end
const Value = Union{Integer,AbstractFloat,AbstractString,Nothing,Missing,Bool,AbstractVector,AbstractDict,Structure}




# Read Functions

# function readMessage(protocol::BoltSession{BoltVersion{1}})

# end

# function readChunk(protocol::BoltSession{BoltVersion{1}})

# end

# unserialize Functions


# serialize functions

Base.write(protocol::BoltSession{BoltVersion{1}}, ::Union{Nothing,Missing}) = write(protocol.socket,0xC0)

Base.write(protocol::BoltSession{BoltVersion{1}}, bool::Bool) = bool ? write(protocol.socket,0xC3) : write(protocol.socket,0xC2)

function Base.write(protocol::BoltSession{BoltVersion{1}}, int::Integer)
	n = write(protocol.socket,0xCB)
	n += write(protocol.socket,hton(Int64(int)))
	return n
end

Base.write(protocol::BoltSession{BoltVersion{1}}, f::AbstractFloat) = write(protocol,Float64(f))

function Base.write(protocol::BoltSession{BoltVersion{1}}, f::Float64)
	n = write(protocol.socket,0xC1)
	n += write(protocol.socket, hton(f))
	return n
end

function Base.write(protocol::BoltSession{BoltVersion{1}}, str::AbstractString)
	s = sizeof(str)
	n = 0
	if s < 0x10
		n += write(protocol.socket, 0x80 | UInt8(s))
	elseif s <= 0xFF
		n += write(protocol.socket, 0xD0)
		n += write(protocol.socket, UInt8(s))
	elseif s <= 0xFFFF
		n += write(protocol.socket, 0xD1)
		n += write(protocol.socket, UInt16(s))
	else
		n += write(protocol.socket, 0xD2)
		n += write(protocol.socket, UInt32(s))
	end

	n += write(protocol.socket,s)
end

function Base.write(protocol::BoltSession{BoltVersion{1}}, list::AbstractVector)

end

end