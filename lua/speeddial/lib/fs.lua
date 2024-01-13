local logger = SpeeddialGlobal.logger
local Path = require("plenary.path")

local M = {}

---@param path Path
function M.change_directory(path)
  if path:exists() then
    vim.fn.execute("cd " .. tostring(path:absolute()), "silent")
    return true
  else
    logger:warn("path does not exist", path:absolute())
    return false
  end
end

--
---@param path_str string
---@return Path
function M.normalize(path_str)
  return Path:new(Path:new(path_str):expand())
end

return M
