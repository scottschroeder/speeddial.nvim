local helpers = require("speeddial.tests.helpers")
local Path = require("plenary.path")

local eq, neq = helpers.eq, helpers.neq

describe("speeddial.lib.gitutil", function()
  local gitutil = require("speeddial.lib.gitutil")
  describe("git config parsing", function()
    it("find git config", function()
      eq("foo/.git/config", gitutil._git_config_file(Path:new("foo")):normalize())
    end)

    it("parse name from url (github)", function()
      eq("user/repo", gitutil._parse_repo_name_from_url("  url = https://github.com/user/repo"))
    end)

    -- TODO
    -- it("parse name from url (file)", function()
    --   eq("repo", gitutil.parse_repo_name_from_url("  url = /path/to/repo"))
    -- end)

    it("parse remote name", function()
      eq("origin", gitutil._parse_remote_name('[remote "origin"]'))
    end)

    it("do not parse config which is not remote name", function()
      eq(nil, gitutil._parse_remote_name('[branch "main"]'))
    end)


    it("parse remotes", function()
      local config = {
        '[core]',
        '	ignorecase = true',
        '[submodule]',
        '	active = .',
        '[remote "origin"]',
        '	url = https://github.com/fork_user/repo',
        '	fetch = +refs/heads/*:refs/remotes/origin/*',
        '[branch "main"]',
        '	remote = origin',
        '	merge = refs/heads/main',
        '[remote "upstream"]',
        '	fetch = +refs/heads/*:refs/remotes/upstream/*',
        '	url = https://github.com/user/repo',
        '[remote "local"]',
        '	fetch = +refs/heads/*:refs/remotes/upstream/*',
        '	url = /path/to/checkout/of/local/repo',
      }

      eq({
        origin = "fork_user/repo",
        upstream = "user/repo",
        __last = "user/repo", -- TODO this should parse the local url correctly
      }, gitutil._parse_git_remotes(config))
    end)
  end)
end)
