local log = require("speeddial.log")
local fs = require("speeddial.lib.fs")
local project = require("speeddial.lib.project")

M = {}

---@param db speeddial.lib.projectdb.ProjectDB
---@param opts table
---@return speeddial.lib.project.Project[]
local enumerate_selectable_impl = function(db, opts)
  opts = opts or {}

  local select_from = {}

  for _, v in pairs(db.projects) do
    select_from[#select_from + 1] = v
  end

  return select_from
end

---@param db speeddial.lib.projectdb.ProjectDB
---@param opts table
---@return speeddial.lib.project.Project[]
function M.enumerate_selectable(db, opts)
  return enumerate_selectable_impl(db, opts)
end

local create_source = function(proj)
  return "[" .. proj.source .. "]"
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

---@param db speeddial.lib.projectdb.ProjectDB
---@param opts table
function M.select_impl(db, opts)
  opts = opts or {}
  local select_from = enumerate_selectable_impl(db, opts)

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
      log.debug("selected project", choice.title)
      fs.change_directory(project.get_project_root(choice))
      if opts.after ~= nil then
        opts.after(choice)
      end
    end
  )
end

return M
