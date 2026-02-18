

--print("table registry required")

--print(debug.traceback())

TableReg = {}

function HandleRegTable(hId, oId)

    if (TableReg[hId]) then
        -- gdebug(string.format('[Table Registry]: warning, repeated handle registered - %d', hId))
    end
    
    if (hId) then 
        TableReg[hId] = oId        
        -- gdebug(string.format('[Table Registry]: register handle - %d', hId))
        dbg.handle_ref(hId)
    else
        -- gdebug(string.format('[Table Registry]: prevent register nil handle, oId - %d', oId))
    end

    return oId
end

function HandleGetTable(hId)
    return TableReg[hId]
end

function HandleRemoveTable(hId)
    local oId = TableReg[hId]
    TableReg[hId] = nil

    -- gdebug(string.format('[Table Registry]: handle unregister - %d', hId))
    dbg.handle_unref(hId)

    return oId
end