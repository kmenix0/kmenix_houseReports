CreateThread(function()

    local riskLevel = 4
    local spawnedCar = 0
    local currentPosK = 0
    local currentPosV = 0
    local spawnedPed = {}
    local security = {}
    security = {
        vehicles = {
            `dilettante2`
        },
        peds = {
            `s_m_m_security_01`,
            `cs_prolsec_02`,
            `csb_prolsec`,
            `s_m_m_security_01`
        },
        bodyguards = {
            1, 
            math.random(1,2), 
            math.random(2,3),
            math.random(2,4)
        },
        gunTypes = {
            `weapon_flashlight`,
            `weapon_stungun_mp`,
            `weapon_pistol`,
            `weapon_combatpistol`
        },
        isGunHold = {false, false, false, true},
    }
    local houseLocation = {}
    houseLocation[1] = {
        name = "Płd. Mo Milton Dr",
        door = vec3(-876.91, 306.2, 84.15),
        gate = vec3(-850.06, 301.96, 86.24)
    }
    houseLocation[2] = {
        name = "Dunstable Ln",
        door = vec3(-882.01, 364.34, 85.36),
        gate = vec3(-864.82, 386.37, 87.5)
    }
    houseLocation[3] = {
        name = "Occupation Ave",
        door = vec3(115.12, -271.19, 50.51),
        gate = vec3(109.47, -292.74, 45.95)
    }
    houseLocation[4] = {
        name = "Paleto Blvd",
        door = vec3(-15.12, 6557.58, 33.24),
        gate = vec3(-4.0, 6555.81, 31.94)
    }
    houseLocation[5] = {
        name = "Movie Star Way",
        door = vec3(-914.73, -455.59, 39.6),
        gate = vec3(-931.04, -461.4, 37.14)
    }
    houseLocation[6] = {
        name = "Fleeca Bank Hawick Ave",
        door = vec3(-349.73, -45.52, 49.04),
        gate = vec3(-333.5, -38.57, 47.87)
    }
    houseLocation[7] = {
        name = "Fleeca Bank Route 68",
        door = vec3(1174.61, 2701.48, 38.17),
        gate = vec3(1173.91, 2694.87, 37.89)
    }

    i = 1
    while i < #houseLocation do
        blip = AddBlipForCoord(houseLocation[i]["door"])
        SetBlipSprite(blip, 363)
        SetBlipColour(blip, 1)
        SetBlipScale(blip, 0.75)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Rabunek mieszkania")
        EndTextCommandSetBlipName(blip)

        i=i+1
    end

    function GetRandomNearbyPositionOnRoad(x, y, z, radius)
        local found, spawnPos, spawnHeading
        for k = 1, 15 do
            local randomOffsetX = math.random(-radius, radius)
            local randomOffsetY = math.random(-radius, radius)
            found, spawnPos, spawnHeading = GetNthClosestVehicleNodeWithHeading(x + randomOffsetX, y + randomOffsetY, z, 1, 0, 0, 0)
            if found then break end
        end
        return found, spawnPos, spawnHeading
    end

    function GetVehicleOccupancy(vehicle)
        local maxSeats = GetVehicleMaxNumberOfPassengers(vehicle)
        local occupiedSeats = 0
        
        for seatIndex = -1, maxSeats - 1 do
            local pedInSeat = GetPedInVehicleSeat(vehicle, seatIndex)
            if pedInSeat ~= 0 and pedInSeat ~= PlayerPedId() then
                occupiedSeats = occupiedSeats + 1
            end
        end
        
        return occupiedSeats
    end

    function startRobbery()
        print("Zacząłeś kradzież!")
    end

    function startRobberyWithAlarm(robberHere)
        print("Zacząłeś kradzież, ale uruchomił się cichy alarm!")
        local finishCarModel = security["vehicles"][math.random(1,#security["vehicles"])]
        local finishPedModel = {}
        if not IsModelInCdimage(finishCarModel) then return end
            RequestModel(finishCarModel)
        local found, spawnPos, spawnHeading = GetRandomNearbyPositionOnRoad(robberHere["gate"].x, robberHere["gate"].y, robberHere["gate"].z, 250)
        if found then
            spawnedCar = CreateVehicle(finishCarModel, spawnPos.x, spawnPos.y, spawnPos.z, spawnHeading, true, false)
            SetVehicleEngineOn(spawnedCar, true, true, true)

            local i = 1
            while i <= security["bodyguards"][riskLevel] do
                finishPedModel[i] = security["peds"][math.random(1,#security["peds"])]
                if not IsModelInCdimage(finishPedModel[i]) then return end
                    RequestModel(finishPedModel[i])
                spawnedPed[i] = CreatePed(4, finishPedModel[i], true, true)
                AddRelationshipGroup("SECURITY_GUARD")
                SetEntityHealth(spawnedPed[i], 200)
                SetPedArmour(spawnedPed[i], 100)
                SetPedPropIndex(spawnedPed[i], 0, math.random(0,2), 0, true)
                SetPedPropIndex(spawnedPed[i], 1, math.random(0,1), 0, true)
                GiveWeaponToPed(spawnedPed[i], security["gunTypes"][riskLevel], 128, true, security["isGunHold"][riskLevel])
                SetRelationshipBetweenGroups(0, `SECURITY_GUARD`, `SECURITY_GUARD`)
                SetPedRelationshipGroupHash(spawnedPed[i], `SECURITY_GUARD`)
                AddBlipForEntity(spawnedPed[i])
                TaskWarpPedIntoVehicle(spawnedPed[i], spawnedCar, i-2)

                i=i+1
            end
            Wait(10)

            SetDriverAbility(spawnedPed[1], 1.0)
            TaskVehicleDriveToCoordLongrange(spawnedPed[1], spawnedCar, robberHere["gate"], 15.0, 263100, 5.0)
            local carLocation = 0
            local pedCoords = {}
            local vehicleFull = false
            local occupiedSeatsF = 0
            local j = 1
            local p = 1
            while j <= security["bodyguards"][riskLevel] or p <= security["bodyguards"][riskLevel] do
                Wait(0)
                carLocation = GetEntityCoords(spawnedCar)
                if #(robberHere["gate"]-carLocation) < 7.5 then
                    Wait(2000)
                    while j <= security["bodyguards"][riskLevel] do
                        TaskLeaveVehicle(spawnedPed[j], spawnedCar, 1)
                        Wait(750)
                        SetCurrentPedWeapon(spawnedPed[j], security["gunTypes"][riskLevel], security["isGunHold"][riskLevel])
                        TaskGoToCoordAnyMeans(spawnedPed[j], robberHere["door"], 1.0, 0, 0, 786603, 0xbf800000)

                        j=j+1
                    end

                    while p <= security["bodyguards"][riskLevel] do
                        Wait(0)
                        pedCoords[p] = GetEntityCoords(spawnedPed[p])

                        if #(pedCoords[p]-robberHere["door"]) < 1.5 then
                            Wait(2500)
                            TaskEnterVehicle(spawnedPed[p], spawnedCar, -1, p-2, 1.0, 1)

                            p=p+1
                        end
                    end

                    while not vehicleFull do
                        Wait(0)
                        occupiedSeatsF = GetVehicleOccupancy(spawnedCar)
                        if security["bodyguards"][riskLevel] == occupiedSeatsF then
                            vehicleFull = true
                            Wait(2000)
                            TaskVehicleDriveWander(spawnedPed[1],spawnedCar, 15.0, 956)
                            Wait(30000)
                            DeleteEntity(spawnedCar)
                            DeletePed(spawnedPed[1])
                            DeletePed(spawnedPed[2])
                            DeletePed(spawnedPed[3])
                            DeletePed(spawnedPed[4])
                        end
                    end
                end
            end
        end
    end

    while true do
        Wait(0)
        local PlayerCoords = GetEntityCoords(PlayerPedId())

        for k, v in pairs(houseLocation) do
            if #(v["door"] - PlayerCoords) < 25.0 then
                currentPosK = k
                currentPosV = v["door"]
            end
        end

        if currentPosK ~= 0 then
            if #(houseLocation[currentPosK]["door"]-PlayerCoords) < 20.0 then
                DrawMarker(27, currentPosV-vec3(0.0,0.0,0.95), 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 1.5, 1.5, 1.0, 255, 25, 25, 100, false, true, 2, true, nil, nil, false)
                if #(houseLocation[currentPosK]["door"] - PlayerCoords) < 1.5/2 then
                    BeginTextCommandDisplayHelp('STRING')
                    AddTextComponentSubstringPlayerName("Naciśnij ~INPUT_CONTEXT~ aby ~r~rozpocząć rabunek~w~ "..houseLocation[currentPosK]["name"])
                    EndTextCommandDisplayHelp(0, false, true, 0)
                    if IsControlJustPressed(0, 38) then
                        if math.random(1,5)==1 then -- szansa
                            startRobbery(houseLocation[currentPosK])
                        else
                            startRobberyWithAlarm(houseLocation[currentPosK])
                        end
                    end
                end
            end
        end
    end
end)