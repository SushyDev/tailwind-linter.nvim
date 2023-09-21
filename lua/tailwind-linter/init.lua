local class_list_order_raw = require('tailwind-linter.class_list_order')

-- Define global vim
local vim = vim or { }

local M = {
    options = {
        prefix = "",
        message = "Tailwind classes are not in the correct order.",
        type = "@error",
        languages = { "html", "astro" },
    },
}

local H = { }

local class_list_order = vim.json.decode(class_list_order_raw)

local tailwind_linter = vim.api.nvim_create_namespace('tailwind_linter')

H.splitString = function(input)
    local words = {}

    for word in input:gmatch("%S+") do
        table.insert(words, word)
    end

    return words
end

-- Function to find common items between two lists
H.findCommonItems = function(base, items)
    local commonItems = {}
    local itemsSet = {}

    -- Create a set from list2 for efficient look-up
    for _, item in ipairs(base) do
        itemsSet[item] = true
    end

    -- Find common items in list1
    for _, item in ipairs(items) do
        if itemsSet[item] then
            table.insert(commonItems, item)
        end
    end

    return commonItems
end

-- Function to compare the sort order of two lists
H.compareSortOrder = function(base, items)
    local i, j = 1, 1 -- Initialize pointers for both lists

    while i <= #base and j <= #items do
        if base[i] == items[j] then
            -- If the elements match, move to the next element in both lists
            i = i + 1
            j = j + 1
        else
            -- If the elements don't match, only move to the next element in list1
            i = i + 1
        end
    end

    -- If we've reached the end of list2, it means all elements in list2 were found in list1 in the same order
    return j > #items
end

H.compareLists = function(_class_list_order, class_list)
    -- Find the common items between the two lists
    local commonItems = H.findCommonItems(_class_list_order, class_list)

    -- Check if the common items are in the same order in both lists
    if not H.compareSortOrder(_class_list_order, commonItems) then
        return false
    end

    return true
end

H.clearExtmarks = function(bufnr)
    local extmarks = vim.api.nvim_buf_get_extmarks(bufnr, tailwind_linter, 0, -1, {})

    -- Loop through the list of extmarks and delete each one
    for _, extmark in ipairs(extmarks) do
        local extmark_id = extmark[4]
        vim.api.nvim_buf_del_extmark(bufnr, tailwind_linter, extmark_id)
    end
end

H.handleMatches = function(matches, bufnr)
    vim.api.nvim_buf_clear_namespace(bufnr, tailwind_linter, 0, -1)

    for _, match in ipairs(matches) do
        local class_list = H.splitString(match.text)

        if not H.compareLists(class_list_order, class_list) then
            vim.api.nvim_buf_set_extmark(bufnr, tailwind_linter, match.row, 0, { end_line = match.row, end_col = 0, virt_text = { { M.options.prefix .. M.options.message, M.options.type} } })
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

    local languages = "{" .. table.concat(M.options.languages, ",") .. "}"

    vim.cmd([[
    augroup AutoSave
        autocmd!
        autocmd BufRead,BufEnter,BufWritePost *.]] .. languages .. [[ lua CheckClassOrder()
    augroup END
    ]])
end

return M
