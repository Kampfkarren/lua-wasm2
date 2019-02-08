return function(wasm)
	it("should have basic math operations", function()
		expect(wasm.exports.add(5)).to.equal(15)
		expect(wasm.exports.sub(3)).to.equal(7)
		expect(wasm.exports.mul(3)).to.equal(30)
		expect(wasm.exports.div(18)).to.equal(9)
	end)
end
