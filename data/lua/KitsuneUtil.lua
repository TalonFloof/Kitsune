local util = {}

function util.lerp(a,b,t) return 1-(a+(b-a)*t) end

return util