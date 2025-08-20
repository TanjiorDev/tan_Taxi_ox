local ESX = exports["es_extended"]:getSharedObject()
local jobName = "taxi"
local taxiEmployees = {}

-- 📋 Ouvre le menu BOSS avec solde dynamique
function OpentaxiMenu()
    ESX.TriggerServerCallback("tanjiro:getSocietyMoney", function(societyMoney)
        local label = "Coffre : " .. (societyMoney or "Chargement...") .. " $"

        lib.registerMenu({
            id = 'taxi_boss_menu',
            title = '👮‍♂️ Gestion taxi',
            position = 'top-right',
            options = {
                {label = label, icon = 'vault'},
                {
                    label = 'Déposer argent société',
                    icon = 'money-bill-transfer',
                    args = { action = 'deposit' }
                },
                {
                    label = 'Retirer argent société',
                    icon = 'money-bill-wave',
                    args = { action = 'withdraw' }
                },
                {
                    label = 'Gestion des employés',
                    icon = 'folder-open',
                    args = { goToSub = true }
                }
            }
        }, function(selected, scrollIndex, args)
            if args then
                if args.action == 'deposit' then
                    local input = lib.inputDialog("Déposer dans la société", {
                        {type = "number", label = "Montant", min = 1}
                    })
                    if input and input[1] then
                        TriggerServerEvent("tanjiro:boss:deposit", jobName, input[1])
                    end
                elseif args.action == 'withdraw' then
                    local input = lib.inputDialog("Retirer de la société", {
                        {type = "number", label = "Montant", min = 1}
                    })
                    if input and input[1] then
                        TriggerServerEvent("tanjiro:boss:withdraw", jobName, input[1])
                    end
                elseif args.goToSub then
                    lib.showMenu('taxi_boss_submenu')
                end
            end
        end)

        lib.showMenu('taxi_boss_menu')
    end, jobName)
end

-- 🧍 Sous-menu dynamique des employés
function OpenEmployeeListMenu()
    GettaxiEmployees(function()
        local options = {
            {label = 'Retour', icon = 'arrow-left', args = { back = true }}
        }

        for _, employee in pairs(taxiEmployees) do
            table.insert(options, {
                label = employee.name .. " [" .. employee.grade .. "]",
                icon = 'user',
                args = { selectedName = employee.name }
            })
        end

        lib.registerMenu({
            id = 'taxi_employee_list',
            title = 'Liste des employés',
            position = 'top-right',
            options = options
        }, function(selected, scrollIndex, args)
            if args then
                if args.back then
                    lib.showMenu("taxi_boss_submenu")
                elseif args.selectedName then
                    ESX.ShowNotification("Employé sélectionné : " .. args.selectedName)
                end
            end
        end)

        lib.showMenu('taxi_employee_list')
    end)
end

-- 👨‍💼 Menu Gestion des employés (statique)
lib.registerMenu({
    id = 'taxi_boss_submenu',
    title = 'Gestion des employés',
    position = 'top-right',
    options = {
        {label = 'Retour', icon = 'arrow-left', args = { back = true }},
        {label = 'Recruter un joueur proche', icon = 'user-plus', args = { action = 'recruit' }},
        {label = 'Promouvoir joueur proche', icon = 'arrow-up', args = { action = 'promote' }},
        {label = 'Virer joueur proche', icon = 'user-slash', args = { action = 'fire' }},
        {label = 'Liste des employes', icon = 'users', args = { action = 'list' }},
    }
}, function(selected, scrollIndex, args)
    if args then
        if args.back then
            OpentaxiMenu()
        elseif args.action == 'recruit' then
            local player, dist = ESX.Game.GetClosestPlayer()
            if player ~= -1 and dist < 3.0 then
                TriggerServerEvent("tanjiro:experimentetaxi", GetPlayerServerId(player))
                ESX.ShowNotification("Joueur recruté")
            else
                ESX.ShowNotification("~r~Aucun joueur proche")
            end
        elseif args.action == 'promote' then
            local player, dist = ESX.Game.GetClosestPlayer()
            if player ~= -1 and dist < 3.0 then
                TriggerServerEvent("tanjiro:chieftaxi", GetPlayerServerId(player))
                ESX.ShowNotification("Joueur promu")
            else
                ESX.ShowNotification("~r~Aucun joueur proche")
            end
        elseif args.action == 'fire' then
            local player, dist = ESX.Game.GetClosestPlayer()
            if player ~= -1 and dist < 3.0 then
                TriggerServerEvent("tanjiro:virertaxi", GetPlayerServerId(player))
                ESX.ShowNotification("Employé viré")
            else
                ESX.ShowNotification("~r~Aucun joueur proche")
            end
        elseif args.action == 'list' then
            OpenEmployeeListMenu()
        end
    end
end)

function GettaxiEmployees(cb)
    ESX.TriggerServerCallback("gettaxiEmployees", function(employees)
        taxiEmployees = employees
        cb()
    end)
end

-- 📦 Zone ox_target via Config
CreateThread(function()
    local data = Config.Boss.TaxiBoss

    exports.ox_target:addBoxZone({
        coords = data.coords,
        size = data.size,
        rotation = 0,
        distance = data.bossMenu.distance or 2.5,
        debug = false,
        options = {
            {
                label = data.bossMenu.label or "Menu Patron",
                icon = data.bossMenu.icon or "fas fa-user-shield",
                canInteract = function()
                    local xPlayer = ESX.GetPlayerData()
                    return xPlayer.job and xPlayer.job.name == data.society and xPlayer.job.grade >= data.bossMenu.requiredGrade
                end,
                onSelect = function()
                    OpentaxiMenu()
                end
            }
        }
    })
end)

