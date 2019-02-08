local Int = require(script.Int)

local Types = {}

function Types.parse(returnType, value)
	-- TODO: prevent possible intentional fake type param?
	if type(value) == "table" and value.type == returnType then
		return value
	end

	if returnType == "i32" then
		return Int.new(returnType, value)
	else
		error("unknown return type " .. tostring(returnType))
	end
end

return Types
