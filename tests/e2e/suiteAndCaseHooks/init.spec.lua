return function()
    describe("My suite", function()
        it("My nested case", function()
        end)
    end)

    it("My case", function()
    end)

    it("My failing case", function()
        error("My failure")
    end)
end