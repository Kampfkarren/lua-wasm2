return function(wasm)
	it("should return 42 as an import function", function()
		expect(wasm.exports.main()).to.be.equal(42)
	end)
end
