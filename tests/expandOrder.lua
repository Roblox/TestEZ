-- luacheck: globals it beforeAll afterAll

local TestEZ = require(script.Parent.Parent.TestEZ)

return {
	["init.spec.lua is run before children are expanded"] = function()
		local initialized = false

		local plan = TestEZ.TestPlanner.createPlan({
			{
				method = function()
					assert(initialized, "init.spec was not called before bar.spec")
				end,
				path = {'bar.spec', 'foo'},
				pathStringForSorting = "foo bar.spec",
			},
			{
				method = function()
					initialized = true
				end,
				path = {'foo'},
				pathStringForSorting = "foo",
			},
		})

		local results = TestEZ.TestRunner.runPlan(plan)
		assert(#results.errors == 0, "init test failed: " .. tostring(results.errors[1]))
	end,
	["init.spec.lua afterAll can correctly undo changes"] = function()
		local initialized = false

		local plan = TestEZ.TestPlanner.createPlan({
			{
				method = function()
					it("A", function()
						assert(not initialized, "initialized was true in foo/a.spec")
					end)
				end,
				path = {'a.spec', 'foo'},
				pathStringForSorting = "foo a.spec",
			},
			{
				method = function()
					it("B", function()
						assert(initialized, "initialized was false in foo/bar/b.spec")
					end)
				end,
				path = {'b.spec', 'bar', 'foo'},
				pathStringForSorting = "foo bar b.spec",
			},
			{
				method = function()
					beforeAll(function()
						initialized = true
					end)

					afterAll(function()
						initialized = false
					end)
				end,
				path = {'bar', 'foo'},
				pathStringForSorting = "foo bar",
			},
			{
				method = function()
					it("C", function()
						assert(initialized, "initialized was false in foo/bar/c.spec")
					end)
				end,
				path = {'c.spec', 'bar', 'foo'},
				pathStringForSorting = "foor bar c.spec",
			},
			{
				method = function()
					it("D", function()
						assert(not initialized, "initialized was true in foo/d.spec")
					end)
				end,
				path = {'d.spec', 'foo'},
				pathStringForSorting = "foo d.spec",
			},
		})

		local results = TestEZ.TestRunner.runPlan(plan)
		assert(#results.errors == 0, "init test failed:\n" ..
			table.concat(results.errors, "\n"))
	end,
}
