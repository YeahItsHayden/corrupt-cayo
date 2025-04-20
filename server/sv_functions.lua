local config = require 'config/sv_config'
local sConfig = require ('config.sh_config')

globalNotify = function(msg) -- change to any type of notify you want tbh
    if config['globalNotify'] then 
        TriggerClientEvent('chat:addMessage', -1, {
            color = { 34, 139, 230 },
            multiline = true,
            args = { msg }
        }) 
    end
end

-- take moeny from person
lib.callback.register('corrupt-cases:removeDeposit', function(source)
    if sConfig['framework'] == 'qbx' then
        if exports.qbx_core:GetMoney(source, 'bank') >= sConfig['vehicle'].amount then 
            exports.qbx_core:RemoveMoney(source, 'bank', sConfig['vehicle'].amount, 'Cost of Vehicle Deposit for Cayo Car')
            return true
        else
            return false
        end
    elseif sConfig['framework'] == 'esx' then 
        local xPlayer = ESX.GetPlayerFromId(source)
        local balance = xPlayer.getAccount('bank').money
        
        if balance >= sConfig['vehicle'].amount then 
            xPlayer.removeAccountMoney('bank', sConfig['vehicle'].amount)
            return true
        else 
            return false
        end
    end
end)