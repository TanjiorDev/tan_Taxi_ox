ESX = exports["es_extended"]:getSharedObject()

--Coffre

-- Charger la configuration
Citizen.CreateThread(function()
    -- Attente pour être sûr que la config est prête
    Wait(1000)

    -- Vérification de l'activation de la ressource "ox_inventory"
    AddEventHandler('onServerResourceStart', function(resourceName)
        if resourceName == 'ox_inventory' or resourceName == GetCurrentResourceName() then
            Wait(0)
            -- Enregistrement du coffre taxi avec les paramètres de config.lua
            exports.ox_inventory:RegisterStash(
                Config.TaxiService.coffre.id,        -- Identifiant du coffre
                Config.TaxiService.coffre.label,     -- Label du coffre
                Config.TaxiService.coffre.slots,     -- Nombre de slots
                Config.TaxiService.coffre.weight,    -- Poids
                Config.TaxiService.coffre.owner     -- Propriétaire
            )
        end
    end)
end)





TriggerEvent('esx_phone:registerNumber', 'taxi', 'alerte taxi', true, true)

TriggerEvent('esx_society:registerSociety', 'taxi', 'taxi', 'society_taxi', 'society_taxi', 'society_taxi', {type = 'public'})

RegisterServerEvent('Ouvre:taxi')
AddEventHandler('Ouvre:taxi', function()
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local xPlayers	= ESX.GetPlayers()
	for i=1, #xPlayers, 1 do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		TriggerClientEvent('ox_lib:notify', _source, {
			title = 'Les taxis sont désormais ouverts!',
			type = 'inform'
		})
	end
end)

RegisterServerEvent('Ferme:taxi')
AddEventHandler('Ferme:taxi', function()
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local xPlayers	= ESX.GetPlayers()
	for i=1, #xPlayers, 1 do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		TriggerClientEvent('ox_lib:notify', _source, {
			title = 'Les taxis sont désormais fermés',
			type = 'inform'
		})
	end
end)

RegisterServerEvent('Recru:taxi')
AddEventHandler('Recru:taxi', function()
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local xPlayers	= ESX.GetPlayers()
	for i=1, #xPlayers, 1 do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		TriggerClientEvent('ox_lib:notify', _source, {
			title = 'Recrutement en cours, rendez-vous au taxi !',
			type = 'inform'
		})
	end
end)

RegisterNetEvent('taxiperso')
AddEventHandler('taxiperso', function(msg)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local xPlayers    = ESX.GetPlayers()
    for i=1, #xPlayers, 1 do
        local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
        TriggerClientEvent('esx:showAdvancedNotification', xPlayers[i], 'taxi', '~p~Annonce', msg, 'CHAR_TREVOR', 8)
    end
end)



-- Mission 

-- Event: FinishMission
RegisterNetEvent('taxi:payPlayerAndCompany', function(playerPay, companyPay)
    local xPlayer = ESX.GetPlayerFromId(source)

    if playerPay > 0 then
        xPlayer.addMoney(playerPay)
        TriggerClientEvent('esx:showNotification', source, ("~g~Vous avez reçu %s$ pour cette mission."):format(playerPay))
    end

    if companyPay > 0 and xPlayer.job.grade_name == 'boss' then
        TriggerEvent('esx_addonaccount:getSharedAccount', 'society_taxi', function(account)
            account.addMoney(companyPay)
        end)
        TriggerClientEvent('esx:showNotification', source, ("~g~L'entreprise a reçu %s$."):format(companyPay))
    end
end)



--##############################
--############ Accueil ##########
--##############################


--##############################
--############ taxi CV ##########
--##############################


RegisterNetEvent('taxi:envoyerNotification', function(message)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    -- Fonction pour envoyer un message au webhook
    local function sendToWebhook(content)
        local embed = {
            {
                ["color"] = 16753920, -- Couleur de l'embed (orange ici)
                ["title"] = "Notification taxi",
                ["description"] = content,
                ["footer"] = {
                    ["text"] = os.date("%d/%m/%Y %H:%M:%S"), -- Date et heure actuelle
                },
            }
        }
        PerformHttpRequest(Config.WebhookURLplaintes, function(err, text, headers) end, "POST", json.encode({embeds = embed}), {["Content-Type"] = "application/json"})
    end

    -- Vérifiez si le joueur a le job taxi
    if xPlayer.getJob().name == "taxi" then
        TriggerClientEvent('esx:showNotification', src, '~g~Vous avez envoyé une notification aux taxis !')

        -- Notifiez tous les taxis et envoyez la notification au webhook
        for _, playerId in pairs(ESX.GetPlayers()) do
            local targetPlayer = ESX.GetPlayerFromId(playerId)

            if targetPlayer and targetPlayer.getJob().name == "taxi" then
                TriggerClientEvent('esx:showNotification', playerId, '~b~[Notification taxi]~s~ ' .. message)
            end
        end

        -- Envoyer la notification au webhook
        sendToWebhook("**Message de notification :** " .. message .. "\n**Envoyé par :** " .. xPlayer.getName())
    else
        TriggerClientEvent('esx:showNotification', src, '~r~Vous n\'êtes pas un taxi !')
    end
end)


-- boss
local ESX = exports["es_extended"]:getSharedObject()

RegisterServerEvent("tanjiro:boss:deposit")
AddEventHandler("tanjiro:boss:deposit", function(society, amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    amount = tonumber(amount)
    if amount and amount > 0 and xPlayer.getMoney() >= amount then
        xPlayer.removeMoney(amount)
        TriggerEvent('esx_addonaccount:getSharedAccount', 'society_' .. society, function(account)
            account.addMoney(amount)
        end)
        TriggerClientEvent('esx:showNotification', source, "💰 Vous avez déposé ~g~" .. amount .. "$~s~.")
    else
        TriggerClientEvent('esx:showNotification', source, "~r~Montant invalide ou fonds insuffisants.")
    end
end)

RegisterServerEvent("tanjiro:boss:withdraw")
AddEventHandler("tanjiro:boss:withdraw", function(society, amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    amount = tonumber(amount)
    TriggerEvent('esx_addonaccount:getSharedAccount', 'society_' .. society, function(account)
        if account.money >= amount then
            account.removeMoney(amount)
            xPlayer.addMoney(amount)
            TriggerClientEvent('esx:showNotification', source, "💸 Vous avez retiré ~g~" .. amount .. "$~s~.")
        else
            TriggerClientEvent('esx:showNotification', source, "~r~Fonds de société insuffisants.")
        end
    end)
end)

ESX.RegisterServerCallback("tanjiro:getSocietyMoney", function(source, cb, society)
    TriggerEvent('esx_addonaccount:getSharedAccount', 'society_' .. society, function(account)
        if account then
            cb(account.money)
        else
            cb(0)
        end
    end)
end)


-- Recruter (grade 0)
RegisterServerEvent('tanjiro:recrutertaxi')
AddEventHandler('tanjiro:recrutertaxi', function(target)
	local sourceXPlayer = ESX.GetPlayerFromId(source)
	if sourceXPlayer.getJob().grade_name == 'boss' then
		local targetXPlayer = ESX.GetPlayerFromId(target)
		targetXPlayer.setJob(sourceXPlayer.getJob().name, 0)
		notifyZUI(source, "Recrutement", ("~g~Vous avez recruté %s"):format(targetXPlayer.name))
		notifyZUI(target, "Recrutement", ("~g~Vous avez été recruté par %s"):format(sourceXPlayer.name))
	end
end)

-- Licencier
RegisterServerEvent('tanjiro:virertaxi')
AddEventHandler('tanjiro:virertaxi', function(target)
	local sourceXPlayer = ESX.GetPlayerFromId(source)
	local targetXPlayer = ESX.GetPlayerFromId(target)
	if sourceXPlayer.job.grade_name == 'boss' and sourceXPlayer.job.name == targetXPlayer.job.name then
		targetXPlayer.setJob('unemployed', 0)
		notifyZUI(source, "Licenciement", "Vous avez ~r~viré~s~ "..targetXPlayer.name)
		notifyZUI(target, "Licenciement", "Vous avez été ~r~viré~s~ par "..sourceXPlayer.name)
	else
		notifyZUI(source, "Erreur", "~r~Vous n'avez pas l'autorisation")
	end
end)

-- Novice (grade 1)
RegisterServerEvent('tanjiro:novicetaxi')
AddEventHandler('tanjiro:novicetaxi', function(target)
	local sourceXPlayer = ESX.GetPlayerFromId(source)
	if sourceXPlayer.getJob().grade_name == 'boss' then
		local targetXPlayer = ESX.GetPlayerFromId(target)
		targetXPlayer.setJob(sourceXPlayer.getJob().name, 1)
		notifyZUI(source, "Promotion", ("~g~%s promu au grade Novice"):format(targetXPlayer.name))
		notifyZUI(target, "Promotion", ("~g~Vous avez été promu au grade Novice par %s"):format(sourceXPlayer.name))
	end
end)

-- Expérimenté (grade 2)
RegisterServerEvent('tanjiro:experimentetaxi')
AddEventHandler('tanjiro:experimentetaxi', function(target)
	local sourceXPlayer = ESX.GetPlayerFromId(source)
	if sourceXPlayer.getJob().grade_name == 'boss' then
		local targetXPlayer = ESX.GetPlayerFromId(target)
		targetXPlayer.setJob(sourceXPlayer.getJob().name, 2)
		notifyZUI(source, "Promotion", ("~g~%s promu au grade Expérimenté"):format(targetXPlayer.name))
		notifyZUI(target, "Promotion", ("~g~Vous avez été promu au grade Expérimenté par %s"):format(sourceXPlayer.name))
	end
end)

-- Chef (grade 3)
RegisterServerEvent('tanjiro:chieftaxi')
AddEventHandler('tanjiro:chieftaxi', function(target)
	local sourceXPlayer = ESX.GetPlayerFromId(source)
	if sourceXPlayer.getJob().grade_name == 'boss' then
		local targetXPlayer = ESX.GetPlayerFromId(target)
		targetXPlayer.setJob(sourceXPlayer.getJob().name, 3)
		notifyZUI(source, "Promotion", ("~g~%s promu au grade Chef"):format(targetXPlayer.name))
		notifyZUI(target, "Promotion", ("~g~Vous avez été promu au grade Chef par %s"):format(sourceXPlayer.name))
	end
end)

ESX.RegisterServerCallback('gettaxiEmployees', function(source, cb)
    local xPlayers = ESX.GetExtendedPlayers('job', 'taxi') -- Compatible avec ESX Legacy
    local employees = {}

    for _, xPlayer in pairs(xPlayers) do
        table.insert(employees, {
            name = xPlayer.getName(),
            grade = xPlayer.job.grade_label
        })
    end

    cb(employees)
end)

