local helpers = require("speeddial.tests.helpers")
local Path = require("plenary.path")

local eq, neq = helpers.eq, helpers.neq

describe("speeddial.lib.fs", function()
  describe("normalize", function()
    local normalize = require("speeddial.lib.fs").normalize
    local Path = require("plenary.path")
    it("dot is current dir", function()
      local cwd = vim.fn.getcwd()

      local abs_path = normalize("."):absolute()
      eq(abs_path, cwd)
    end)

    it("eliminate single dot", function()
      local abs_path = normalize("/path/./to/file"):absolute()
      eq(abs_path, "/path/to/file")
    end)

    it("eliminate double dot", function()
      local abs_path = normalize("/path/to/../file"):absolute()
      eq(abs_path, "/path/file")
    end)

    it("deref homedir", function()
      local home = vim.loop.os_getenv("HOME") or "<NO HOME ENV VAR>"
      local abs_path = normalize("~"):absolute()
      eq(abs_path, home)
    end)

    it("normalize existing path", function()
      local p = Path:new("/foo")
      local abs_path = normalize(p):absolute()
      eq("/foo", abs_path)
    end)
  end)
end)
