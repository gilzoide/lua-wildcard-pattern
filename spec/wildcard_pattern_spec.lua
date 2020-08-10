local wildcard_pattern = require 'wildcard_pattern'

local function should_match(pattern, name)
    assert.are.same(name, name:match(pattern))
end
local function should_not_match(pattern, name)
    assert.is_nil(name:match(pattern))
end

describe("When building wildcards,", function()
    it("simple non-special characters match literals only", function()
        local pattern = wildcard_pattern.from_wildcard("hello world")
        should_match(pattern, "hello world")
        should_not_match(pattern, "helloworld")
        should_not_match(pattern, "hello")
        should_not_match(pattern, "")
        should_not_match(pattern, "hello world mío")
    end)

    it("special characters to lua patterns are escaped", function()
        local pattern = wildcard_pattern.from_wildcard(".+")
        should_match(pattern, '.+')
        should_not_match(pattern, ' .+')
        should_not_match(pattern, '.+ ')
        should_not_match(pattern, 'hello world')
        should_not_match(pattern, '.')

        pattern = wildcard_pattern.from_wildcard(".-")
        should_match(pattern, '.-')
        should_not_match(pattern, ' .-')
        should_not_match(pattern, '.- ')
        should_not_match(pattern, 'hello world')
        should_not_match(pattern, '')

        pattern = wildcard_pattern.from_wildcard("%d")
        should_match(pattern, '%d')
        should_not_match(pattern, '0')
        should_not_match(pattern, '9')
        should_not_match(pattern, '')

        pattern = wildcard_pattern.from_wildcard("a(.)")
        should_match(pattern, 'a(.)')
        should_not_match(pattern, 'aa')
        should_not_match(pattern, 'ab')
        should_not_match(pattern, 'a.')
    end)

    it("'*' matches anything but '/'", function()
        local pattern = wildcard_pattern.from_wildcard("*.lua")
        should_match(pattern, "wildcard_pattern.lua")
        should_match(pattern, "ends with .lua")
        should_not_match(pattern, "spec/wildcard_pattern_spec.lua")
        should_not_match(pattern, "ends without . but only lua")
    end)

    it("'**' matches anything", function()
        local pattern = wildcard_pattern.from_wildcard("**.lua")
        should_match(pattern, "wildcard_pattern.lua")
        should_match(pattern, "ends with .lua")
        should_match(pattern, "spec/wildcard_pattern_spec.lua")
        should_not_match(pattern, "ends without . but only lua")
        should_not_match(pattern, "ends without . but only lua")
    end)

    it("'?' matches any single character but '/'", function()
        local pattern = wildcard_pattern.from_wildcard("?")
        should_match(pattern, '?')
        should_match(pattern, 'a')
        should_match(pattern, 'z')
        should_match(pattern, '0')
        should_match(pattern, '9')
        should_match(pattern, '.')
        should_not_match(pattern, '')
        should_not_match(pattern, '??')
    end)

    it("'\\' escaped characters are still escaped", function()
        local pattern = wildcard_pattern.from_wildcard("\\*")
        should_match(pattern, '*')
        should_not_match(pattern, '')
        should_not_match(pattern, 'a')
        should_not_match(pattern, 'some_file.txt')

        pattern = wildcard_pattern.from_wildcard("maybe\\?")
        should_match(pattern, 'maybe?')
        should_not_match(pattern, 'maybe!')
        should_not_match(pattern, 'maybe')
    end)

    it("'[]' delimit character sets", function()
        local pattern = wildcard_pattern.from_wildcard("[0-9].txt")
        print(pattern)
        should_match(pattern, '0.txt')
        should_match(pattern, '1.txt')
        should_match(pattern, '5.txt')
        should_match(pattern, '9.txt')
        should_not_match(pattern, '0')
        should_not_match(pattern, '0.lua')
        should_not_match(pattern, '10.txt')
    end)
end)
