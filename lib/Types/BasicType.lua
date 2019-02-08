local BasicType = {}

for _, op in pairs({
	"Add",
	"Sub",
	"Mul",
	"DivS",

	"LtS",
	"GtS",
}) do
	BasicType[op] = function()
		error(("can't add %s to %s"):format(op, self.type))
	end
end

function BasicType:ToLua()
	error("can't serialize type to lua: " .. self.type)
end

return BasicType
