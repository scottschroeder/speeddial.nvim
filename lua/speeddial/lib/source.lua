
---@class speeddial.lib.source.Source
---@field git speeddial.lib.source.GitSource|nil
---@field project speeddial.lib.source.ProjectSource|nil

---@class speeddial.lib.source.GitSource
---@field title string: short descriptive name
---@field base string: the directory to scan for git repos

---@class speeddial.lib.source.ProjectSource
---@field title string: short descriptive name
---@field root string: the directory for CWD
---@field vcs_root string: the directory containing the VCS root




local M = {}


return M
