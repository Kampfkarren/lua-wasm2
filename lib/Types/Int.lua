local Int = setmetatable({}, require(script.Parent.BasicType))
Int.__index = Int

local mathError = "argument passed to %s is not %s"

function Int:_MathError(op)
	return function()
		error(mathError:format(op, self.type))
	end
end

function Int:Add(number)
	assert(number.type == self.type, self:_MathError("add"))
	return Int.new(self.type, self:ToLua() + number:ToLua())
end

function Int:Sub(number)
	assert(number.type == self.type, self:_MathError("sub"))
	return Int.new(self.type, self:ToLua() - number:ToLua())
end

function Int:Mul(number)
	assert(number.type == self.type, self:_MathError("mul"))
	return Int.new(self.type, self:ToLua() * number:ToLua())
end

function Int:DivS(number)
	assert(number.type == self.type, self:_MathError("div_s"))
	return Int.new(self.type, math.floor(self:ToLua() / number:ToLua()))
end

function Int:GtS(number)
	assert(number.type == self.type, self:_MathError("gt_s"))
	return Int.bool(self.type, number:ToLua() > self:ToLua())
end

function Int:LtS(number)
	assert(number.type == self.type, self:_MathError("lt_s"))
	return Int.bool(self.type, number:ToLua() < self:ToLua())
end

function Int:ToLua()
	return self.value
end

function Int.bool(type, bool)
	assert(bool == true or bool == false, "non bool passed: " .. tostring(bool))
	return Int.new(type, bool and 1 or 0)
end

function Int.new(type, value)
	return setmetatable({
		type = type,
		value = assert(tonumber(value), "non int passed: " .. tostring(value)),
	}, Int)
end

return Int
