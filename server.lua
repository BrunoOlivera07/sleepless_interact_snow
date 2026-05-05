RegisterNetEvent('Interact:SetHoldProps', function(props)
    local source = source
    Player(source).state:set('interact:holdProps', props, true)
end)
