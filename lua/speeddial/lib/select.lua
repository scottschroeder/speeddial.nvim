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

local create_source = function(project)
  return "[" .. project.source .. "]"
end

local get_max_len_source = function(projects)
  local max_len_source = 0

  for _, v in ipairs(projects) do
    local s = create_source(v)
    local slen = string.len(s)
    if slen > max_len_source then
      max_len_source = slen
    end
  end
  return max_len_source
end

---@param db ProjectDB
---@param opts table
function M.select_impl(db, opts)
  opts = opts or {}
  local select_from = M.enumerate_selectable(db, opts)

  local source_buffer = get_max_len_source(select_from)

  vim.ui.select(
    select_from,
    {
      format_item = function(item)
        local source = create_source(item)
        local padding_len = source_buffer - string.len(source)
        local padding = string.rep(" ", padding_len)
        return source .. padding .. " " .. item.title
      end,
    },
    function(choice)
      if choice == nil then
        return
      end
      logger:debug("selected project", choice.title)
      fs.change_directory(choice.root)
      if opts.after ~= nil then
        opts.after(choice)
      end
    end
  )
end

return M
