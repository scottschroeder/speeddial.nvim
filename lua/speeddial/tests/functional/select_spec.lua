local helpers = require("speeddial.tests.helpers")

local eq, neq = helpers.eq, helpers.neq

describe("speeddial.lib.select", function()
  local Project = require("speeddial.lib.project").Project
  local ProjectDB = require("speeddial.lib.projectdb").ProjectDB
  local select_mod = require("speeddial.lib.select")

  it("empty selection is empty", function()
    local db = ProjectDB({})
    local actual = select_mod.enumerate_selectable(db, {})
    eq({}, actual)
  end)

  it("nonempty selection is not empty", function()
    local db = ProjectDB({})
    db:add(Project({ vcs_root = "/foo" }))
    db:add(Project({ vcs_root = "/bar" }))

    local actual = select_mod.enumerate_selectable(db, {})

    eq(2, #actual)

    table.sort(actual, function(lhs, rhs)
      return lhs:as_path() < rhs:as_path()
    end)

    eq("/bar", actual[1]:as_path())
    eq("/foo", actual[2]:as_path())
  end)
end)
