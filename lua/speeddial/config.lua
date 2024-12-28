local utils = require("speeddial.utils")

local M = {}

local setup_done = false

---@class SpeeddialConfig
M.defaults = {
  switch = false,
  sources = {}
}
-- stylua: ignore end

M._config = M.defaults


---@return SpeeddialConfig
function M.get_config()
  if not setup_done then
    M.setup()
  end

  return M._config
end

function M.setup(user_config)
  user_config = user_config or {}

  M._config = vim.tbl_deep_extend(
    "force",
    utils.tbl_deep_clone(M.defaults),
    user_config
  )

  setup_done = true
end

return M
