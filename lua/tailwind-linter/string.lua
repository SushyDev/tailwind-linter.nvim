local M = {}

M.split = function(input)
    local words = {}

    for word in input:gmatch("%S+") do
        table.insert(words, word)
    end

    return words
end

return M
