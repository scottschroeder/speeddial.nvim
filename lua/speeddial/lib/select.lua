local logger = SpeeddialGlobal.logger
local lazy = require("speeddial.lazy")
local fs = lazy.require("speeddial.lib.fs") ---@module "speeddial.lib.fs"

M = {}

---@param db ProjectDB
---@param opts table
---@return Project[]
function M.enumerate_selectable(db, opts)
  opts = opts or {}

  local select_from = {}

  for _, v in pairs(db:projects()) do
    select_from[#select_from + 1] = v
  end

  return select_from
end

---@param db ProjectDB
---@param opts table
function M.select_impl(db, opts)
  opts = opts or {}
  local select_from = M.enumerate_selectable(db, opts)

  vim.ui.select(
    select_from,
    {
      format_item = function(item)
        return item.title .. " - " .. item:as_path()
      end,
    },
    function(choice)
      logger:debug("selected project", choice.title)
      fs.change_directory(choice.root)
      if opts.after ~= nil then
        opts.after(choice)
      end
    end
  )
end

return M
