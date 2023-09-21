-- Define global vim
local vim = vim or { }

local M = {
    options = {
        message = "Class order is not alphabetical",
        type = "Error",
    },
}

local H = { }

local tailwind_linter = vim.api.nvim_create_namespace('tailwind_linter')

H.splitString = function(input)
    local words = {}

    for word in input:gmatch("%S+") do
        table.insert(words, word)
    end

    return words
end

H.isAlphabeticalOrder = function(table)
    for i = 1, #table - 1 do
        if table[i] > table[i + 1] then
            return false
        end
    end

    return true
end

H.clearExtmarks = function(bufnr)
    local extmarks = vim.api.nvim_buf_get_extmarks(bufnr, tailwind_linter, 0, -1, {})

    -- Loop through the list of extmarks and delete each one
    for _, extmark in ipairs(extmarks) do
        -- local line, col = extmark[2], extmark[3]
        local extmark_id = extmark[4]
        vim.api.nvim_buf_del_extmark(bufnr, tailwind_linter, extmark_id)
    end
end

H.handleMatches = function(matches, bufnr)
    vim.api.nvim_buf_clear_namespace(bufnr, tailwind_linter, 0, -1)

    for _, match in ipairs(matches) do
        local words = H.splitString(match.text)
        if not H.isAlphabeticalOrder(words) then
            vim.api.nvim_buf_set_extmark(bufnr, tailwind_linter, match.row, 0, { end_line = match.row, end_col = 0, virt_text = { { M.options.message, "WarningMsg" } } })
        end
    end
end

function CheckClassOrder()
    -- Buffer
    local bufnr = vim.api.nvim_get_current_buf()
    local bufferLang = vim.api.nvim_buf_get_option(bufnr, 'filetype')

    -- Get the parser for the current buffer
    local parser = vim.treesitter.get_parser(bufnr, bufferLang)
    local tree = parser:parse()
    local root = tree[1]:root()

    -- Query
    local query = vim.treesitter.query.parse(bufferLang, [[
        (attribute
            (attribute_name) @_name (#eq? @_name "class")
            (quoted_attribute_value (attribute_value) @value)
        )
    ]])

    local matches = {}

    for _, match in query:iter_matches(root, bufnr, 0, 0) do
        for id, node in pairs(match) do
            if query.captures[id] == "value" then
                local text = vim.treesitter.get_node_text(node, bufnr)
                local row = node:range()

                table.insert(matches, { text = text, row = row })
            end
        end
    end

    H.handleMatches(matches, bufnr)
end

function M.setup(opts)
    -- Merge user-provided options with defaults
    M.options = vim.tbl_deep_extend("force", M.options, opts or {})

    vim.cmd([[
    augroup AutoSave
        autocmd!
        autocmd BufRead,BufEnter,BufWritePost *.{html} lua CheckClassOrder()
    augroup END
    ]])
end

return M
