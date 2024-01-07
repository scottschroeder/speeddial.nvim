-- Overall state for all known projects

local lazy = require("speeddial.lazy")

local oop = require("speeddial.oop")

local projectmodule = lazy.require("speeddial.lib.project") ---@module "speeddial.lib.project"

local Project = projectmodule.Project


local M = {}

---@class ProjectDB : speeddial.Object
---@operator call : ProjectDB
---@field data : table
---@field state_file string
local ProjectDB = oop.create_class("ProjectDB")
M.ProjectDB = ProjectDB


---@param opts table
function ProjectDB:init(opts)
  opts = opts or {}
  self.data = {}
end

---@param project Project
function ProjectDB:add(project)
  self.data[project:as_path()] = project
end

return M
