local bt = {}
local config = {}

local function get_builtin(ft)
  local prettier = {
    cmd = 'prettier',
    args = { '--stdin-filepath' },
    fname = true,
    stdin = true,
  }

  local builtin = {
    c = {
      cmd = 'clang-format',
      args = { '-style=file' },
      find = '.clang-format',
      fname = false,
      stdin = true,
    },
    cpp = {
      cmd = 'clang-format',
      args = { '-style=file' },
      find = '.clang-format',
      fname = false,
      stdin = true,
    },
    rust = {
      cmd = 'rustfmt',
      args = { '--edition', '2021', '--emit', 'stdout' },
      fname = false,
      stdin = true,
    },
    go = {
      cmd = 'golines',
      args = { '--max-len=80' },
      fname = false,
      stdin = true,
      before = function()
        vim.lsp.buf.code_action({ context = { only = { 'source.organizeImports' } }, apply = true })
      end,
    },
    lua = {
      cmd = 'stylua',
      find = '.stylua.toml',
      args = { '-' },
      stdin = true,
    },
    typescript = prettier,
    typescriptreact = prettier,
    javascript = prettier,
    javascriptreact = prettier,
  }

  return builtin[ft]
end

bt.__index = bt

function bt.use_default(fts)
  for _, ft in pairs(fts) do
    config[ft] = true
  end
end

function bt.__newindex(t, k, v)
  local conf = get_builtin(k)
  if not conf then
    conf = {}
  end
  v = type(v) == 'boolean' and {} or v

  conf = vim.tbl_extend('force', conf, v)
  if vim.fn.executable(conf.cmd) == 0 then
    vim.notify('[EasyFormat] ' .. conf.cmd .. ' not executable', vim.log.levels.Error)
    return
  end
  rawset(t, k, conf)
end

return setmetatable(config, bt)