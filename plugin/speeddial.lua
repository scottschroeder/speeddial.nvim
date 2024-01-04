if vim.g.speeddial_nvim_loaded then
  return
end
-- if vim.g.speeddial_nvim_loaded or not require("speeddial.bootstrap") then
--   return
-- end

vim.g.speeddial_nvim_loaded = 1

local lazy = require("speeddial.lazy")

-- ---@module "speeddial"
-- local arg_parser = lazy.require("speeddial.arg_parser") ---@module "speeddial.arg_parser"
-- local speeddial = lazy.require("speeddial") ---@module "speeddial"

-- local api = vim.api
-- local command = api.nvim_create_user_command

-- NOTE: Need this wrapper around the completion function becuase it doesn't
-- exist yet.
-- local function completion(...)
--   return speeddial.completion(...)
-- end

-- -- Create commands
-- command("SpeeddialOpen", function(ctx)
--   speeddial.open(arg_parser.scan(ctx.args).args)
-- end, { nargs = "*", complete = completion })

-- command("SpeeddialFileHistory", function(ctx)
--   local range

--   if ctx.range > 0 then
--     range = { ctx.line1, ctx.line2 }
--   end

--   speeddial.file_history(range, arg_parser.scan(ctx.args).args)
-- end, { nargs = "*", complete = completion, range = true })

-- command("SpeeddialClose", function()
--   speeddial.close()
-- end, { nargs = 0, bang = true })

-- command("SpeeddialFocusFiles", function()
--   speeddial.emit("focus_files")
-- end, { nargs = 0, bang = true })

-- command("SpeeddialToggleFiles", function()
--   speeddial.emit("toggle_files")
-- end, { nargs = 0, bang = true })

-- command("SpeeddialRefresh", function()
--   speeddial.emit("refresh_files")
-- end, { nargs = 0, bang = true })

-- command("SpeeddialLog", function()
--   vim.cmd(("sp %s | norm! G"):format(
--     vim.fn.fnameescape(SpeeddialGlobal.logger.outfile)
--   ))
-- end, { nargs = 0, bang = true })
