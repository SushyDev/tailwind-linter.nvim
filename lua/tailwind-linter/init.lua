local marks = require('tailwind-linter.marks')
local sorter = require('tailwind-linter.sorter')
local string = require('tailwind-linter.string')
local order = require('tailwind-linter.order')

local M = {
    options = {
        prefix = "",
        message = "Tailwind classes are not in the correct order.",
        type = "@error",
        languages = { "html", "php" },
    },
}

local class_list_order = vim.json.decode(order)
local namespace = vim.api.nvim_create_namespace('tailwind_linter')

local function handleMatches(matches, bufnr)
    marks.clear(bufnr, namespace)

    for _, match in ipairs(matches) do
        local class_list = string.split(match.text)

        if not sorter.compareLists(class_list_order, class_list) then
            local message = M.options.prefix .. " " .. M.options.message
            local type = M.options.type
            marks.create(bufnr, namespace, match.row, message, type)
        end
    end
end

local query_html = [[
    (attribute
        (attribute_name) @_name (#eq? @_name "class")
        (quoted_attribute_value (attribute_value) @value)
    )
]]

function CheckClassOrder()
    -- Buffer
    local bufnr = vim.api.nvim_get_current_buf()
    local bufferLang = vim.api.nvim_buf_get_option(bufnr, 'filetype')

    if bufferLang == "php" then
        bufferLang = "html"
    end

    -- Get the parser for the current buffer
    local parser = vim.treesitter.get_parser(bufnr, bufferLang)
    local tree = parser:parse()
    local root = tree[1]:root()

    -- Query
    local query = vim.treesitter.query.parse("html", query_html)

    if not query then
        return
    end

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

    handleMatches(matches, bufnr)
end

function M.setup(opts)
    -- Merge user-provided options with defaults
    M.options = vim.tbl_deep_extend("force", M.options, opts or {})

    local languages = "{" .. table.concat(M.options.languages, ",") .. "}"

    vim.cmd([[
    augroup AutoSave
        autocmd!
        autocmd BufRead,BufEnter,BufWritePost *.]] .. languages .. [[ lua CheckClassOrder()
    augroup END
    ]])
end

return M
