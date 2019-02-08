local LOAD_MODULES = {
	{"lib", "Library"},
	{"test", "IntegrationTests"},
	{"vendor/testez/lib", "TestEZ"},
}

package.path = package.path .. ";?/init.lua"

local lemur = require("vendor.lemur")

local habitat = lemur.Habitat.new()

local Root = lemur.Instance.new("Folder")
Root.Name = "Root"

for _, module in pairs(LOAD_MODULES) do
	local container = habitat:loadFromFs(module[1])
	container.Name = module[2]
	container.Parent = Root
end

local integrationTests = lemur.Instance.new("Folder")

for _, integrationTest in pairs(Root.IntegrationTests:GetChildren()) do
	local jsonFile = assert(io.open("test/" .. integrationTest.Name .. "/test.json", "r"))
	local json = habitat.game:GetService("HttpService"):JSONDecode(jsonFile:read("*all"))
	jsonFile:close()

	local imports = integrationTest:FindFirstChild("imports")
	if imports then
		imports = habitat:require(imports)
	end

	local testModule = integrationTest.test
	testModule.Name = testModule.Name .. ".spec"
	local test = habitat:require(testModule)
	getmetatable(testModule).instance.moduleResult = function()
		return setfenv(
			test,
			setmetatable(
				{},
				{ __index = getfenv() }
			)
		)(
			habitat:require(Root.Library).new(json, imports)
		)
	end
end

local TestEZ = habitat:require(Root.TestEZ)

local results = TestEZ.TestBootstrap:run({ Root.Library, Root.IntegrationTests }, TestEZ.Reporters.TextReporter)

if results.failureCount > 0 then
	os.exit(1)
end
