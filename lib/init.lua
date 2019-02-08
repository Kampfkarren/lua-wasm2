local Function = require(script.Function)
local Types = require(script.Types)

local function fetchExport(self, exportName)
	return self.wasm._exports[exportName]()
end

local WebAssembly = {}

function WebAssembly.new(data, imports)
	imports = imports or {}

	local wasm = {}
	wasm._exports = {}
	wasm.code = {}
	wasm.functions = {}
	wasm.imports = {
		code = {},
		functions = {},
	}
	wasm.types = {}

	-- create all the code so far
	for _, section in ipairs(data) do
		if section.name == "code" then
			for _, entry in ipairs(section.entries) do
				local funcIndex = #wasm.code + 1

				wasm.code[funcIndex] = Function.new(wasm, funcIndex, function(locals, typeSignature)
					local stack = {}
					for _, code in ipairs(entry.code) do
						if code.name == "add" then
							local sum = table.remove(stack):Add(table.remove(stack))
							stack[#stack + 1] = sum
						elseif code.name == "call" then
							local calleeIndex = tonumber(code.immediates) + 1
							local calleeTypeSignature = Function.GetTypeSignatureFromFuncIndex(wasm, calleeIndex)
							local callStack = {}
							for index = 1, #calleeTypeSignature.params do
								callStack[#calleeTypeSignature.params - index + 1] = assert(table.remove(stack), "call stack exhausted")
							end
							stack[#stack + 1] = wasm.code[calleeIndex](unpack(callStack))
						elseif code.name == "const" then
							stack[#stack + 1] = Types.parse(code.return_type, code.immediates)
						elseif code.name == "div_s" then
							local arg1 = table.remove(stack)
							local arg2 = table.remove(stack)
							stack[#stack + 1] = arg2:DivS(arg1)
						elseif code.name == "end" then
							-- TODO: end instr
						elseif code.name == "get_local" then
							local localIndex = tonumber(code.immediates) + 1
							stack[#stack + 1] = assert(locals[localIndex], "can't get local at index " .. localIndex)
						elseif code.name == "gt_s" then
							local result = table.remove(stack):GtS(table.remove(stack))
							stack[#stack + 1] = result
						elseif code.name == "lt_s" then
							local result = table.remove(stack):LtS(table.remove(stack))
							stack[#stack + 1] = result
						elseif code.name == "mul" then
							local product = table.remove(stack):Mul(table.remove(stack))
							stack[#stack + 1] = product
						elseif code.name == "sub" then
							local arg1 = table.remove(stack)
							local arg2 = table.remove(stack)
							stack[#stack + 1] = arg2:Sub(arg1)
						else
							error("unimplemented instruction " .. code.name)
						end
					end

					if typeSignature.return_type then
						assert(#stack == 1, "leftover stuff on stack, count: " .. #stack)
						local pop = table.remove(stack)
						assert(pop ~= nil, "no return value")
						return pop:ToLua()
					else
						assert(#stack == 0, "leftover stuff on stack, count: " .. #stack)
					end
				end)
			end
		elseif section.name == "export" then
			for _, entry in ipairs(section.entries) do
				if entry.kind == "function" then
					wasm._exports[entry.field_str] = function()
						return assert(wasm.code[entry.index + 1], "couldn't find function to export")
					end
				elseif entry.kind == "memory" then
					-- TODO: what do we do with memory?
				else
					error("don't know how to work with export of kind " .. entry.kind)
				end
			end
		elseif section.name == "function" then
			for index, entry in ipairs(section.entries) do
				wasm.functions[index] = entry + 1
			end
		elseif section.name == "import" then
			for _, entry in ipairs(section.entries) do
				if entry.moduleStr == "env" then
					if entry.kind == "function" then
						local funcIndex = #wasm.imports.code + 1

						wasm.imports.code[funcIndex] = Function.new(wasm, funcIndex, function(locals, typeSignature)
							local map = {}
							for _, variable in ipairs(locals) do
								map[#map + 1] = variable:ToLua()
							end
							local callback = imports[entry.fieldStr](unpack(map))

							if typeSignature.return_type then
								return Types.parse(typeSignature.return_type, callback)
							end
						end)

						wasm.imports.functions[funcIndex] = tonumber(entry.type) + 1
					else
						error("unimplemented import entry kind: " .. entry.kind)
					end
				else
					error("don't know what to import with module string " .. entry.moduleStr)
				end
			end
		elseif section.name == "type" then
			wasm.types = section.entries
		end
	end

	-- adjust code with imports
	local adjustedCode = {}

	for _, import in ipairs(wasm.imports.code) do
		adjustedCode[#adjustedCode + 1] = import
	end

	for _, code in ipairs(wasm.code) do
		local adjustedFuncIndex = #adjustedCode + 1
		code.funcIndex = adjustedFuncIndex
		adjustedCode[adjustedFuncIndex] = code
	end

	wasm.code = adjustedCode

	-- adjust function indices
	local adjustedFunctions = {}

	for _, import in ipairs(wasm.imports.functions) do
		adjustedFunctions[#adjustedFunctions + 1] = import
	end

	for _, func in ipairs(wasm.functions) do
		adjustedFunctions[#adjustedFunctions + 1] = func
	end

	wasm.functions = adjustedFunctions

	wasm.exports = setmetatable({
		wasm = wasm,
	}, {
		__index = fetchExport,
	})

	return wasm
end

return WebAssembly
