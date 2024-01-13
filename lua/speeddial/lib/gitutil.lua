local logger = SpeeddialGlobal.logger
local Path = require("plenary.path")

local M = {}

function M.parse_repo_name_from_url(config_line)
  local s, e = config_line:find("github.com/[^/]+/[^/]+")
  if s then
    local offset = #"github.com/"
    return config_line:sub(s + offset, e)
  end
  return nil
end

local function parse_remote_name(config_line)
  local s, _, remote = config_line:find('%[remote "(%a+)"%]')
  if s then
    return remote
  end
  return nil
end

function M.parse_repo_name_from_git_path(path)
  local remotes = {}
  local last_remote = nil

  local safe_insert = function(name)
    if name == nil then
      return
    end
    remotes["__last"] = name
    if remotes[last_remote] == nil then
      remotes[last_remote] = name
    end
  end

  local safe_remote = function(remote)
    if remote == nil then
      return
    end
    last_remote = remote
  end


  local gitconfig = path:joinpath("/.git/config")
  local ok, lines = pcall(Path.readlines, gitconfig)
  if not ok then
    return nil
  end
  for _, line in pairs(lines) do
    safe_remote(parse_remote_name(line))
    safe_insert(M.parse_repo_name_from_url(line))
  end
  return remotes["upstream"] or remotes["origin"] or remotes["__last"]
end

return M
