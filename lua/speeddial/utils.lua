
local M = {}


---Deep clone a table.
---@generic T : table
---@param t `T`
---@return T
function M.tbl_deep_clone(t)
  local clone = {}

  for k, v in pairs(t) do
    if type(v) == "table" then
      clone[k] = M.tbl_deep_clone(v)
    else
      clone[k] = v
    end
  end

  return clone
end

return M
