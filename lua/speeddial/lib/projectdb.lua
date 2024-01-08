-- Overall state for all known projects

local lazy = require("speeddial.lazy")

local logger = SpeeddialGlobal.logger
local oop = require("speeddial.oop")


local M = {}

---@class ProjectDB : speeddial.Object
---@operator call : ProjectDB
---@field int_projects : table
---@field state_file string
local ProjectDB = oop.create_class("ProjectDB")
M.ProjectDB = ProjectDB


---@param opts table
function ProjectDB:init(opts)
  opts = opts or {}
  self.int_projects = {}
end

---@param project Project
function ProjectDB:add(project)
  -- local ptr = string.format("data: %p", self.int_projects)
  -- logger:debug("add project to db", project:as_path(), "prev:", #self.int_projects, "ptr", ptr)


  self.int_projects[project:as_path()] = project
  -- logger:debug("after add", "len", #self.int_projects, "data", self.int_projects)
end

--
---@return {[string] : Project}
function ProjectDB:projects()
  -- local ptr = string.format("projects: %p", self.int_projects)
  -- logger:debug("int_projects enumerated:", #self.int_projects, "ptr", ptr)
  return self.int_projects
end

return M
