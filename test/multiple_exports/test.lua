return function(wasm)
	it("should have 2 functional exports", function()
		expect(wasm.exports.one()).to.equal(1)
		expect(wasm.exports.two()).to.equal(2)
	end)
end
