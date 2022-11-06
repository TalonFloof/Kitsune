local util = {}

function util.lerp(a,b,t) return a+(b-a)*t end

function util.FuzzyMatch(string,pattern)
    local score = 0
    local run = 0

    local indexS = 1
    local indexP = 1
    while indexS < #string and indexP < #pattern do
        while string:sub(indexS,indexS) == ' ' do indexS = indexS + 1 end
        while pattern:sub(indexP,indexP) == ' ' do indexP = indexP + 1 end
        if string:sub(indexS,indexS):lower() == pattern:sub(indexP,indexP):lower() then
            score = score + (run * 10 - (string:sub(indexS,indexS) ~= pattern:sub(indexP,indexP) and 1 or 0))
            run = run + 1
            indexP = indexP + 1
        else
            score = score - 10
            run = 0
        end
        indexS = indexS + 1
    end
    if indexP < #pattern then return nil end
    return score - #string
end

function util.FuzzyMatchTable(tab,pattern)
    local result = {}
    for _, i in ipairs(tab) do
        local points = util.FuzzyMatch(tostring(i), pattern)
        if points then
            table.insert(result, { text = i, points = points })
        end
    end
    table.sort(result, function(a,b) return a.points > b.points end)
    return result
end

return util