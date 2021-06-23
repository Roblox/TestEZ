## Inside Tests

### describe
```
describe(phrase: string, callback(context: table))
```

This function creates a new `describe` block. These blocks correspond to the **things** that are being tested.

Put `it` blocks inside of `describe` blocks to describe what behavior should be correct.

For example:

```lua
describe("This cheese", function()
	it("should be moldy", function()
		expect(cheese.moldy).to.equal(true)
	end)
end)
```

### it
```
it(phrase: string, callback(context: table))
```

This function creates a new 'it' block. These blocks correspond to the **behaviors** that should be expected of the thing you're testing.

For example:

```lua
it("should add 1 and 1", function()
	expect(1 + 1).to.equal(2)
end)
```

### expect
```
expect(value: any)
```

Creates a new `Expectation`, used for testing the properties of the given value.

Expectations are intended to be read like English assertions. These are all true:

```lua
-- Equality
expect(1).to.equal(1)
expect(1).never.to.equal(2)

-- Approximate equality
expect(5).to.be.near(5 + 1e-8)
expect(5).to.be.near(5 - 1e-8)
expect(math.pi).never.to.be.near(3)

-- Optional limit parameter
expect(math.pi).to.be.near(3, 0.2)

-- Nil checking
expect(1).to.be.ok()
expect(false).to.be.ok()
expect(nil).never.to.be.ok()

-- Type checking
expect(1).to.be.a("number")
expect(newproxy(true)).to.be.a("userdata")

-- Function throwing
expect(function()
	error("nope")
end).to.throw()

expect(function()
	-- I don't throw!
end).never.to.throw()

expect(function()
	error("nope")
end).to.throw("nope")

expect(function()
	error("foo")
end).never.to.throw("bar")
```

### Lifecycle hooks

The lifecycle hooks are a collection of blocks similar to `it` blocks. They
can be used to collect setup and teardown code into a common place.

When placed in an `init.spec.lua` file, these hooks will run for all tests
within that folder.

!!!note
	The callbacks in the lifecycle hooks are run after all `describe` blocks'
	callbacks. Be careful not to count on setup or teardown code applying to
	code not inside an `it` block.

#### afterAll
```
afterAll(callback(context: table))
```

Returns a function after all the tests within its scope run. This is useful if you want to clean up some global state that is used by other tests within its scope.

For example:

```lua
local DEFAULT_STATE = {
	hello = "world",
}

local globalState = DEFAULT_STATE

afterAll(function()
	globalState = DEFAULT_STATE
end)

it("SHOULD read globalState", function()
	expect(globalState.hello).to.equal("world")
end)

it("SHOULD insert globalState", function()
	globalState.foo = "bar"
	expect(globalState.foo).to.equal("bar")
end)
```

!!!note
	If you want to run some cleanup after every test instead of all tests, use `afterEach` instead.

#### afterEach
```
afterEach(callback(context: table))
```

Returns a function after each of the tests within its scope. This is useful if you want to cleanup some temporary state that is created by each test.
It is always ran regardless of if the test failed or not.

```lua
local DEFAULT_STATE = {
	hello = "world",
}

local globalState = DEFAULT_STATE

afterEach(function()
	globalState = DEFAULT_STATE
end)

it("SHOULD insert globalState", function()
	globalState.foo = "bar"
	expect(globalState.foo).to.equal("bar")
end)

it("SHOULD read globalState", function()
	expect(globalState.hello).to.equal("world")
end)
```

#### beforeAll
```
beforeAll(callback(context: table))
```
Runs a function before any of the tests within its scope run. This is useful if you want to set up state that will be used by other tests within its scope.

For example:

```lua
local globalState = {}

beforeAll(function()
	globalState.foo = "bar"
end)

it("SHOULD have access to globalState", function()
	expect(globalState.foo).to.equal("bar")
end)
```

!!!note
	If you want to run a function before each test instead of before all tests, use `beforeEach` instead.

#### beforeEach
```
beforeEach(callback(context: table))
```

Runs a function before each of the tests within its scope. This is useful if you want to reset global state that will be used by other tests within its scope.

For example:

```lua
local globalState = {}

beforeEach(function()
	globalState.foo = 100
end)

it("SHOULD be able to read foo", function()
	expect(globalState.foo).to.equal(100)
end)

it("SHOULD be able to write foo", function()
	globalState.foo = globalState.foo / 2
	expect(globalState.foo).to.equal(50)
end)
```

!!!note
	If you only need to run some setup code once, before any tests run, use `beforeAll` instead.

## Maintenance and Debugging

### FIXME
```
FIXME(optionalMessage: string)
```

When called inside a `describe` block, `FIXME` is used to identify broken tests and marks the block as *skipped*.

!!!note
	`FIXME` does not work inside an `it` block. The bodies of these blocks aren't executed until the tests run, which is too late to change which tests will run.


### FOCUS
```
FOCUS()
```

When called inside a `describe` block, `FOCUS()` marks that block as *focused*. If there are any focused blocks inside your test tree, *only* focused blocks will be executed, and all other tests will be skipped.

When you're writing a new set of tests as part of a larger codebase, use `FOCUS()` while debugging them to reduce the amount of noise you need to scroll through.

For example:

```lua
describe("Secret Feature X", function()
	FOCUS()

	it("should do something", function()
	end)
end)

describe("Secret Feature Y", function()
	it("should do nothing", function()
		-- This code will not run!
	end)
end)
```

!!! note
	`FOCUS` does not work inside an `it` block. The bodies of these blocks aren't executed until the tests run, which is too late to change which tests will run.

### SKIP
```
SKIP()
```

This function works similarly to `FOCUS()`, except instead of marking a block as *focused*, it will mark a block as *skipped*, which stops any of the test assertions in the block from being executed.

!!!note
	`SKIP` does not work inside an `it` block. The bodies of these blocks aren't executed until the tests run, which is too late to change which tests will run.

### describeFOCUS and describeSKIP
```
describeFOCUS(phrase: string, callback(context: table))
describeSKIP(phrase: string, callback(context: table))
```

These methods are special versions of `describe` that automatically mark the `describe` block as *focused* or *skipped*.

!!!note
	`fdescribe` is an alias for `describeFOCUS`.
	`xdescribe` is an alias for `describeSKIP`.


### itFOCUS, itSKIP, and itFIXME
```
itFOCUS(phrase: string, callback(context: table))
itSKIP(phrase: string, callback(context: table))
itFIXME(phrase: string, callback(context: table))
```

These methods are special versions of `it` that automatically mark the `it` block as *focused* or *skipped*. They're necessary because `FOCUS`, `SKIP`, and `FIXME` can't be called inside `it` blocks!

!!!note
	`fit` is an alias for `itFOCUS`.
	`xit` is an alias for `itSKIP`.


## init.spec.lua

When loading a spec file, TestEZ creates a new `describe` block for each file
and for each folder those files are in. If the file is called `init.spec.lua`,
TestEZ will not create a new `describe` block for it and instead attach any code
inside to the folder's `describe` block. For more on one situation when this
would be useful, see the section on [lifecycle hooks](#lifecycle-hooks).

## Context

As mentioned, `init.spec.lua` allows code to be run as part of a directory's
otherwise-implicit block, and the lifecycle hooks allow setup and teardown code
to be run for all tests within a block. This does indeed mean that a hook inside
an init file will run for all tests in that directory. While hooks within the
same file can pass extra information along to tests via upvalues, hooks in an
init file must use the `context`.

`context` is a write-once table that is passed in to the callbacks for lifecycle
hooks and `it` blocks. Entries in this table are only available to blocks within
the current `describe` block. This means it's safe to add entries without
worrying about influencing tests elsewhere in the tree.

```lua
-- init.spec.lua
return function()
	beforeAll(function(context)
		context.helpers = require(script.Parent.helpers)
	end)
end

-- test.spec.lua
return function()
	it("a test using a helper", function(context)
		local user = context.helpers.makeUser(123)
		-- ...
	end)
end
```

!!! note
	Context is not available to `describe` blocks since they run before any
	lifecycle hooks or `it` blocks.
