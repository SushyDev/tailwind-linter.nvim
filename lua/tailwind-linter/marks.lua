local vim = vim or {}
local M = {}

M.clear = function(bufnr, namespace)
  vim.api.nvim_buf_clear_namespace(bufnr, namespace, 0, -1)
end

M.create = function(bufnr, namespace, rownr, message, type)
  vim.api.nvim_buf_set_extmark(bufnr, namespace, rownr, 0, {
    end_line = rownr,
    end_col = 0,
    virt_text = {
      { message, type }
    }
  })
end

M.setup = function(opts)
  M.options = vim.tbl_deep_extend("force", M.options, opts or {})
end

return M
