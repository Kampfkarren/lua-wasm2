return function(wasm)
	it("should return the argument passed", function()
		expect(wasm.exports.identity(42)).to.be.equal(42)
	end)
end
