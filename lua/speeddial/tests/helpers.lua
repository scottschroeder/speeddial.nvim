local assert = require("luassert")

local M = {}

function M.eq(a, b)
  if a == nil or b == nil then return assert.are.equal(a, b) end
  return assert.are.same(a, b)
end

function M.neq(a, b)
  if a == nil or b == nil then return assert.are_not.equal(a, b) end
  return assert.are_not.same(a, b)
end

return M
