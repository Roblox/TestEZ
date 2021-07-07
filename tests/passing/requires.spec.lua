-- luacheck: globals it expect

return function()
	local a = require(script.Parent.Parent.modules.a)
	local b = require(script.Parent.Parent.modules.b)

	it("requires should work properly", function()
		expect(a).to.equal(2)
		expect(b(2)).to.equal(3)
	end)

	it("require cache works under normal circumstances", function()
		local b2 = require(script.Parent.Parent.modules.b)

		expect(b).to.equal(b2)
	end)
end
