local Path = require("plenary.path")
local normalize = require("speeddial.lib.fs").normalize
local project = require("speeddial.lib.project")

---@class speeddial.lib.projectdb.ProjectDB
---@field projects speeddial.lib.project.Project[]
---@field state_file Path|nil

local M = {}


---@return Path
local get_data_dir = function()
  return normalize(vim.api.nvim_call_function('stdpath', { 'data' }))
end

---@param state_file_opt string|Path|nil: input configuration for state file
---@return Path|nil: resolved path to state file
M._get_state_file = function(state_file_opt)
  if state_file_opt == "" then
    return nil
  end
  if state_file_opt == nil then
    return get_data_dir():joinpath("speeddial_project_db.json")
  end
  return normalize(state_file_opt)
end


---@return speeddial.lib.projectdb.ProjectDB: new DB from opts
M.create_db = function(opts)
  opts = opts or {}

  local state_file = M._get_state_file(opts.state_file)

  return {
    projects = {},
    state_file = state_file
  }
end

---@param projectdb speeddial.lib.projectdb.ProjectDB
---@param p speeddial.lib.project.Project
M.add_project = function(projectdb, p)
  local key = project.as_path(p)
  local prev = projectdb.projects[key]

  if prev == nil then
    projectdb.projects[key] = p
  else
    project.merge(prev, p)
  end
end

---@param projectdb speeddial.lib.projectdb.ProjectDB
---@return integer
M.len = function(projectdb)
  local len = 0
  for _, _ in pairs(projectdb.projects) do
    len = len + 1
  end
  return len
end

return M
