local M = {}

-- Function to find common items between two lists
local function findCommonItems(base, items)
    local commonItems = {}
    local baseSet = {}

    -- Create a set from list2 for efficient look-up
    for _, item in ipairs(base) do
        baseSet[item] = true
    end

    -- Find common items in list1
    for _, item in ipairs(items) do
        if baseSet[item] then
            table.insert(commonItems, item)
        end
    end

    return commonItems
end

-- Function to compare the sort order of two lists
local function compareSortOrder(base, items)
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

    return j > #items
end

local function indexOf(list, item)
    for i, value in ipairs(list) do
        if value == item then
            return i
        end
    end

    return -1
end

local function removeItem(list, item)
    for i, value in ipairs(list) do
        if value == item then
            table.remove(list, i)
            return
        end
    end
end

M.sort = function(base, class_list)
    local commonItems = findCommonItems(base, class_list)

    local sorted_class_list = vim.deepcopy(class_list)

    table.sort(commonItems, function(a, b)
        return indexOf(base, a) < indexOf(base, b)
    end)

    for _, item in ipairs(commonItems) do
        removeItem(sorted_class_list, item)
    end

    for _, item in ipairs(commonItems) do
        table.insert(sorted_class_list, item)
    end

    return sorted_class_list
end

M.compareLists = function(base, class_list)
    local sorted = M.sort(base, class_list)

    return compareSortOrder(class_list, sorted)
end

return M
