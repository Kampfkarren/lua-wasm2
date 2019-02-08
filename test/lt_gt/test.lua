return function(wasm)
	it("should have lt/gt", function()
		expect(wasm.exports.lt(8)).to.equal(0)
		expect(wasm.exports.lt(4)).to.equal(1)
		expect(wasm.exports.lt(5)).to.equal(0)

		expect(wasm.exports.gt(8)).to.equal(1)
		expect(wasm.exports.gt(4)).to.equal(0)
		expect(wasm.exports.gt(5)).to.equal(0)
	end)
end
