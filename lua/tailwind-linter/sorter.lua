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

M.compareLists = function(base, class_list)
    -- Find the common items between the two lists
    local commonItems = findCommonItems(base, class_list)

    -- Check if the common items are in the same order in both lists
    if not compareSortOrder(base, commonItems) then
        return false
    end

    return true
end

return M
