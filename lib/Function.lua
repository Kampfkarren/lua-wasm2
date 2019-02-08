local Types = require(script.Parent.Types)

local Function = {}
Function.__index = Function

function Function.GetTypeSignatureFromFuncIndex(wasm, funcIndex)
	local signatureIndex = assert(wasm.functions[funcIndex], "no function type signature")
	return Function.GetTypeSignatureFromTypeIndex(wasm, signatureIndex)
end

function Function.GetTypeSignatureFromTypeIndex(wasm, typeSignatureIndex)
	local typeSignature = assert(wasm.types[typeSignatureIndex], "no function signature in types")
	assert(typeSignature.form == "func", "type signature isn't for functions")
	return typeSignature
end

function Function:__call(...)
	if not self.typeSignature then
		self.typeSignature = Function.GetTypeSignatureFromFuncIndex(self.wasm, self.funcIndex)
	end

	local locals = {}

	local expectedArgs = select("#", ...)
	assert(
		expectedArgs == #self.typeSignature.params,
		("invalid amount of args expected (%d expected, got %d)")
			:format(#self.typeSignature.params, expectedArgs) -- TODO: better error
	)

	for index = 1, expectedArgs do
		locals[index] = Types.parse(self.typeSignature.params[index], select(index, ...))
	end

	return self.callback(locals, self.typeSignature)
end

function Function.new(wasm, funcIndex, callback)
	return setmetatable(
		{
			callback = callback,
			funcIndex = funcIndex,
			wasm = wasm,
		},
		Function
	)
end

return Function
