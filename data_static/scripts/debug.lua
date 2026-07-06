function Print(x, ...)
    local x = tostring(x)
    for _, v in ipairs({...}) do
        x = x .. " " .. tostring(v)
    end
    
    tm.playerUI.SendChatMessage("server", x)
    tm.os.Log(x)
end