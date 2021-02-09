local TestEZ = require(script.Parent.Parent.TestEZ)

local noOptReporter = {
	report = function()
	end,
}

return {
	["run expect-extend e2e"] = function()
		TestEZ.run(script:FindFirstChild("expect-extend"), function(results)
			assert(#results.errors == 0,
				"Expected no errors, got " .. tostring(results.errors[1]) ..
				" plus " .. tostring(#results.errors - 1) .. " more.")
		end)
	end,

	["run afterEach e2e with error in it block"] = function()
		TestEZ.run(script:FindFirstChild("afterEachAfterFailure"):FindFirstChild("errorInItBlock"), function(results)
			assert(#results.errors == 1, "Expected one error, got " .. tostring(#results.errors))

			local afterEachError = string.find(results.errors[1], "afterEach threw an error as expected")
			assert(afterEachError ~= nil, "Expected afterEach to be reached after it throws an error")

			local cleaningUpError = string.find(results.errors[1], "While cleaning up the failed test another error was found")
			assert(cleaningUpError ~= nil, "Expected 'While cleaning up...' msg to be shown when afterEach fails after it fails")
		end)
	end,

	["run afterEach e2e with failure in it block"] = function()
		TestEZ.run(script:FindFirstChild("afterEachAfterFailure"):FindFirstChild("failureInItBlock"), function(results)
			assert(#results.errors == 1, "Expected one error, got " .. tostring(#results.errors))

			local afterEachError = string.find(results.errors[1], "afterEach threw an error as expected")
			assert(afterEachError ~= nil, "Expected afterEach to be reached after it throws an error")

			local cleaningUpError = string.find(results.errors[1], "While cleaning up the failed test another error was found")
			assert(cleaningUpError ~= nil, "Expected 'While cleaning up...' msg to be shown when afterEach fails after it fails")
		end)
	end,

	["run afterEach e2e with failure in afterEach block"] = function()
		TestEZ.run(script:FindFirstChild("afterEachAfterFailure"):FindFirstChild("errorInAfterEachBlock"), function(results)
			assert(#results.errors == 1, "Expected one error, got " .. tostring(#results.errors))

			local afterEachError = string.find(results.errors[1], "afterEach threw an error as expected")
			assert(afterEachError ~= nil, "Expected afterEach to be reached after it throws an error")

			local cleaningUpError = string.find(results.errors[1], "While cleaning up the failed test another error was found")
			assert(cleaningUpError == nil, "Expected 'While cleaning up...' msg to not be shown when only afterEach fails")
		end)
	end,

	["run lifecycle e2e w/ filter for describe block"] = function()
		TestEZ.TestBootstrap:run({
			script:FindFirstChild("lifecycle"):FindFirstChild("testNameFilterDescribeBlock"),
		},
		noOptReporter,
		{
			testNamePattern = "super specific describe block",
		})
	end,

	["run lifecycle e2e w/ filter for file name"] = function()
		TestEZ.TestBootstrap:run({
			script:FindFirstChild("lifecycle"):FindFirstChild("testNameFilterFileName"),
		},
		noOptReporter,
		{
			testNamePattern = "specificFileName",
		})
	end,

	["suiteAndCaseHooks (onEnterSuite, onEnterCase, onLeaveCase, onLeaveSuite)"] = function()
		local events = {}
		local function eventAppender(eventType)
			return function(...)
				table.insert(events, {eventType, ...})
			end
		end

		TestEZ.TestBootstrap:run({
			script:FindFirstChild("suiteAndCaseHooks"),
		},
		noOptReporter,
		{
			onEnterSuite = eventAppender("onEnterSuite"),
			onLeaveSuite = eventAppender("onLeaveSuite"),
			onEnterCase = eventAppender("onEnterCase"),
			onLeaveCase = eventAppender("onLeaveCase")
		})

		assert(#events == 10)

		assert(events[1][1] == "onEnterSuite")
		assert(events[1][2] == "suiteAndCaseHooks")

		assert(events[2][1] == "onEnterSuite")
		assert(events[2][2] == "My suite")

		assert(events[3][1] == "onEnterCase")
		assert(events[3][2] == "My nested case")

		assert(events[4][1] == "onLeaveCase")
		assert(events[4][2] == "My nested case")

		assert(events[5][1] == "onLeaveSuite")
		assert(events[5][2] == "My suite")

		assert(events[6][1] == "onEnterCase")
		assert(events[6][2] == "My case")

		assert(events[7][1] == "onLeaveCase")
		assert(events[7][2] == "My case")

		assert(events[8][1] == "onEnterCase")
		assert(events[8][2] == "My failing case")

		assert(events[9][1] == "onLeaveCase")
		assert(events[9][2] == "My failing case")
		-- The error from the failing case
		assert(type(events[9][3]) == "string")

		assert(events[10][1] == "onLeaveSuite")
		assert(events[10][2] == "suiteAndCaseHooks")
	end,
}
