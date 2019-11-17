function EventPage1() end

stareFrame = 0
stareShift = 0
eventFrequency = 4500 -- 1m 15s
currEventDone = false
inputted = false
maxStares = 8

function DisplayText(text, faceSprite)
    if type(text) == "table" then
        for i = 1, #text do
            SetGlobal("CYFOWStareText" .. i, text[i])
        end
    else
        SetGlobal("CYFOWStareText1", text)
    end

    if type(faceSprite) == "table" then
        for i = 1, #faceSprite do
            SetGlobal("CYFOWStareFace" .. i, faceSprite[i])
        end
    else
        SetGlobal("CYFOWStareFace1", faceSprite)
    end

    Event.SetPage("Event1", 4)
end

function resetStareVars()
    stare1MovementUpDone = false
    stare2MovementDownDone = false
    stare3DogOpen = false
    stare3InputtedFrame = 0
    stare3DogStartingY = 0
    stare3DogLegsYScale = 0
    stare3InputtedFirst = false
    stare3Count = 0
    stare3DogSpeed = 0
    stare4Count = 0
    stare6Count = 0
    stare6Sprites = nil
    stare6Speeds = nil
end

punderSprite = nil
function Stare1(frame)
    -- run once
    if frame == 0 and not inputted then
        Event.StopCoroutine("Punder")
        if punderSprite == nil then
            punderSprite = Event.GetSprite("Punder")
        end
        -- walk up-left to 320, 320
        Event.MoveToPoint("Punder", 320, 320, true, false)
    end

    -- normal event behavior
    if not inputted then
        -- walk up to 320, 480
        if not stare1MovementUpDone and punderSprite.absx == 320 and punderSprite.absy == 320 then
            stare1MovementUpDone = true
            Event.MoveToPoint("Punder", 320, 480, true, false)
        end
    else
        -- punder actually finished
        if punderSprite.absx == 320 and punderSprite.absy == 480 then
            stareFrame = eventFrequency * 2
            inputted = false
            Stare2(0)
            Event.SetAnimHeader("Punder", "")
            inputted = true
        -- the player pressed a key early
        else
            -- punder has moved through the upwards portion already
            if stare1MovementUpDone then
                -- move down to 320, 320 first
                if punderSprite.absy > 320 then
                    Event.MoveToPoint("Punder", 320, 320, true, false)
                -- then move down-right to 400, 260
                elseif punderSprite.absx ~= 400 and punderSprite.absy ~= 260 then
                    Event.MoveToPoint("Punder", 400, 260, true, false)
                -- end the event
                else
                    Event.SetPage("Punder", 2)
                    return true
                end
            -- punder has not reached 320, 320 by the time the player pressed a key
            else
                -- move straight to 400, 260
                if punderSprite.absx ~= 400 and punderSprite.absy ~= 260 then
                    Event.MoveToPoint("Punder", 400, 260, true, false)
                -- end the event
                else
                    Event.SetPage("Punder", 2)
                    return true
                end
            end
        end
    end
    return false
end

function Stare2(frame)
    if frame == 0 and not inputted then
        Event.Teleport("Punder", 320, 480)
        Event.SetAnimHeader("Punder", "Sun")
        Event.MoveToPoint("Punder", 320, 320, true, false)
    elseif not stare2MovementDownDone and punderSprite.absx == 320 and punderSprite.absy == 320 then
        stare2MovementDownDone = true
        Event.MoveToPoint("Punder", 400, 260, true, false)
    elseif punderSprite.absx == 400 and punderSprite.absy == 260 then
        Event.SetPage("Punder", 2)
        return true
    end
    return false
end

dogSprite = nil
dogPawsSprite = nil
dogLegsSprite = nil
-- Handles the dog's barking animation
function Stare3Bark(frame, maxFrame)
    if frame % 15 == 0 and frame < maxFrame then
        dogSprite.Set("Overworld/Dog" .. (stare3DogOpen and "" or "Bark"))
        stare3DogOpen = not stare3DogOpen
        if stare3DogOpen then
            Audio.PlaySound("Bark")
        end
    end
end

-- Handles the dog's (and his legs if handled) bouncing animation
function Stare3Bounce(frame, handleLegs)
    if frame % 30 <= 15 then
        local scale = 1 + math.sin(frame * math.pi * 2 / 15) * .1
        dogSprite.Scale(scale, 1 / scale)
        if handleLegs then
            dogSprite.absy = stare3DogStartingY - 3 * (1 / stare3DogLegsYScale - 1 / scale * stare3DogLegsYScale)
            dogLegsSprite.Scale(scale, 1 / scale * stare3DogLegsYScale)
            dogPawsSprite.Scale(scale, 1 / scale)
        end
    end
end

function Stare3(frame)
    -- Init: Get the dog's sprite and set some useful variables
    if frame == 0 and not inputted then
        dogSprite = Event.GetSprite("Event1")
        Event.SetSpeed("Event1", 1)
        stare3DogStartingY = dogSprite.absy
    end

    -- Part 1: Dog barks and bounces twice
    if frame <= 60 then
        -- Stops the stare event instantly if the player presses a key during this part
        if inputted then
            dogSprite.Set("Overworld/Dog")
            dogSprite.Scale(1, 1)
            return true
        end
        -- Barking animation, sound and bouncing
        Stare3Bark(frame, 60)
        Stare3Bounce(frame, false)
    -- Part 2: L E G S
    -- If the Player hasn't pressed any key yet
    elseif not inputted then
        if frame >= 90 and frame < 170 then
            -- Init: Creates the legs and paws sprites and move the dog up
            if frame == 90 then
                dogPawsSprite = CreateSprite("Overworld/DogPaws")
                dogPawsSprite.SetPivot(.5, 0)
                dogPawsSprite.MoveToAbs(dogSprite.absx, dogSprite.absy)

                dogLegsSprite = CreateSprite("Overworld/DogLegs")
                dogLegsSprite.SetPivot(.5, 0)
                dogLegsSprite.MoveToAbs(dogSprite.absx, dogSprite.absy + 6)
                Event.MoveToPoint("Event1", dogSprite.absx, dogSprite.absy + 80, true, false)
            end
            -- Scale the legs so that they seem attached to the dog
            dogLegsSprite.yscale = dogLegsSprite.yscale + 1/3
        elseif frame == 170 then
            -- D O G   S U C C E S S F U L L Y   R A I S E D
            Audio.PlaySound("success")
        -- Wait for several seconds...
        elseif frame >= 450 and frame < 510 then
            -- Dog barks twice again and bounces, but this time the legs bounce too!
            -- Init: We store the dog's legs' scale
            if frame == 450 then
                stare3DogLegsYScale = dogLegsSprite.yscale
            end
            -- Barking animation, sound and bouncing
            Stare3Bark(frame, 60)
            Stare3Bounce(frame, true)
        -- Lowers the dog back to normal
        elseif frame >= 510 and frame < 590 then
            if frame == 510 then
                Event.MoveToPoint("Event1", dogSprite.absx, stare3DogStartingY, true, false)
            end
            dogLegsSprite.yscale = dogLegsSprite.yscale - 1/3
        -- Remove the paw sprites and call it a day
        elseif frame == 590 then
            dogLegsSprite.Remove()
            dogPawsSprite.Remove()
            return true
        elseif frame > 590 then
            return true
        end
    -- If the Player pressed a key
    else
        -- If the dog was bouncing with his long legs, reset it back as if he wasn't bouncing
        if frame >= 450 and frame <= 510 and stare3DogLegsYScale ~= 0 then
            dogSprite.absy = stare3DogStartingY + 80
            dogSprite.Scale(1, 1)
            dogLegsSprite.Scale(1, stare3DogLegsYScale)
            dogPawsSprite.Scale(1, 1)
            stare3DogLegsYScale = 0
        end
        -- As long as the leg sprites exist, shorten the legs and keep the dog in midair
        if dogLegsSprite.isactive then
            -- Stop the dog's movement, barking and prepare the legs to be scaled down
            if not stare3InputtedFirst then
                Event.MoveToPoint("Event1", dogSprite.absx, dogSprite.absy, true, false)
                dogSprite.Set("Overworld/Dog")
                stare3DogOpen = false
                dogLegsSprite.SetPivot(.5, 1)
                dogLegsSprite.MoveToAbs(dogSprite.absx, dogSprite.absy + 6)
                stare3InputtedFirst = true
            end
            -- Scale the legs down and raise the paws
            dogLegsSprite.yscale = dogLegsSprite.yscale - 2
            dogPawsSprite.Move(0, 6)
            -- End condition: when the legs are no more, delete the sprites and prepare the dog to fall
            if dogLegsSprite.yscale <= 0 then
                dogLegsSprite.Remove()
                dogPawsSprite.Remove()
                Event.SetSpeed("Event1", 0)
                Event.MoveToPoint("Event1", dogSprite.absx, stare3DogStartingY, true, false)
            end
        -- While the dog is falling...
        elseif dogSprite.absy > stare3DogStartingY then
            -- ...increase his falling speed and rotate him to the side a little
            stare3DogSpeed = stare3DogSpeed + 0.05
            Event.SetSpeed("Event1", stare3DogSpeed)
            dogSprite.rotation = dogSprite.rotation - (dogSprite.rotation < 10 and .5 or dogSprite.rotation < 15 and .25 or .1)
        -- When the dog is on the ground and still rotated, barking or bouncing
        elseif (stare3Count <= 15 or dogSprite.rotation ~= 0 or dogSprite.xscale ~= 1 or stare3DogSpeed > 0) then
            -- Reset the dog's rotation value to 0 over some frames
            if dogSprite.rotation ~= 0 then
                dogSprite.rotation = dogSprite.rotation - math.max(dogSprite.rotation, -2)
            end
            -- Make the dog bounce depending on his downward speed
            local scale = dogSprite.xscale + stare3DogSpeed / 50
            dogSprite.Scale(scale, 1 / scale)
            stare3DogSpeed = (stare3DogSpeed < 0.25 and stare3DogSpeed > 0) and -stare3DogSpeed or (stare3DogSpeed - 0.25)
            if stare3DogSpeed < 0 and dogSprite.xscale < 1 then
                dogSprite.Scale(1, 1)
            end
            -- Make him bark one last time
            Stare3Bark(stare3Count, 16)
            stare3Count = stare3Count + 1
        else
            return true
        end
    end
    return false
end

function Stare4(frame) -- requires at least 574 frames
    -- Create Monster Kid sprite
    if frame == 0 and not inputted then
        mk = CreateSprite("MonsterKidOW/13")
        mk.ypivot = 0
        mk.MoveToAbs(320, -mk.height)
        mk.SetAnimation({"12", "13", "14", "15"}, 0.1875, "MonsterKidOW")
    end

    -- Event is over
    if stare4Count > 0 and not mk then
        return true
    -- Walk up
    elseif stare4Count < 126 then
        mk.absy = mk.absy + 2
    -- Stop walking
    elseif stare4Count == 126 and not inputted then
        mk.StopAnimation()
        mk.Set("MonsterKidOW/13")
    -- Look at Player
    elseif stare4Count == 180 and not inputted then
        mk.Set("MonsterKidOW/9")
    -- Look up
    elseif stare4Count == 360 and not inputted then
        mk.Set("MonsterKidOW/13")
    -- Set animation before walking
    elseif stare4Count == 430 or (stare4Count < 430 and inputted) then
        stare4Count = 430
        mk.SetAnimation({"12", "13", "14", "15"}, 0.1875, "MonsterKidOW")
    -- Walk up
    elseif stare4Count > 430 and mk.absy < 480 then
        mk.absy = mk.absy + 2
    -- Offscreen, remove MK
    elseif stare4Count > 430 and mk.absy >= 480 then
        mk.Remove()
        mk = nil
    end

    stare4Count = mk and stare4Count + 1 or stare4Count
end

function Stare5(frame) DEBUG("Stare5: " .. frame) return true end

boosterSprite = nil
charaSprite = nil
boosterTimestamps = {
    -- Common
    [0] =   { speed = 6,  isHorz = true  }, -- From left to top right loop
    [70] =  { speed = -6, isHorz = false }, -- From top right loop to bottom right loop
    [85] =  { speed = -6, isHorz = true  }, -- From bottom right loop to bottom left loop
    [110] = { speed = 6,  isHorz = false }, -- From bottom left loop to top left loop
    [125] = { speed = 6,  isHorz = true  }, -- From top left loop to top right loop
    [150] = { speed = -6, isHorz = false }, -- From top right loop to bottom right loop
    [165] = { speed = -6, isHorz = true  }, -- From bottom right loop to bottom left loop
    [190] = { speed = 6,  isHorz = false }, -- From bottom left loop to top left loop
    [205] = { speed = 6,  isHorz = true  }, -- From top left loop to top loop
    [220] = { speed = 6,  isHorz = false }, -- From top loop to top
    [260] = { speed = 0 },                  -- Waiting...
    -- Booster-only
    [350] = { speed = 6,  isHorz = true,  instaTP = { x = -40, y = 240 } }, -- From bottom to center
    [410] = { speed = -6, isHorz = false },                                 -- From center to left
    [460] = { speed = 0 },                                                  -- Waiting...
    [520] = { speed = -6, isHorz = false, instaTP = { x = 320, y = 480 } }, -- From top to bottom
    [610] = { speed = 0 },                                                  -- Waiting...
    [700] = { speed = 6,  isHorz = false, instaTP = { x = 320, y = -60 } }, -- From bottom to top behind Chara
    [790] = { speed = 0 },                                                  -- Waiting...
    [830] = { speed = -6, isHorz = false, instaTP = { x = 320, y = 480 } }, -- From top to center
    [860] = { speed = 0,  noSound = true, surprise = true },                -- Encounter bubble and wait
    [895] = { speed = 6,  isHorz = false },                                 -- From center to top
    [935] = { speed = 0 },                                                  -- Already dead
}
charaTimestamps = {
    -- Chara-only
    [420] =  { speed = -6, isHorz = false, instaTP = { x = 320, y = 480 } }, -- From top to bottom
    [510] =  { speed = 0 },                                                  -- Waiting...
    [550] =  { speed = 6,  isHorz = true,  instaTP = { x = -40, y = 240 } }, -- From left to center
    [610] =  { speed = 6,  isHorz = false },                                 -- From center to top
    [650] =  { speed = 0 },                                                  -- Waiting...
    [690] =  { speed = 6,  isHorz = false, instaTP = { x = 320, y = -60 } }, -- From bottom to top
    [780] =  { speed = 0 },                                                  -- Waiting...
    [820] =  { speed = 6,  isHorz = false, instaTP = { x = 320, y = -60 } }, -- From bottom to center
    [860] =  { speed = 0,  noSound = true, surprise = true },                -- Encounter bubble and wait
    [895] =  { speed = 6,  isHorz = false },                                 -- From center to top
    [945] =  { speed = 0 },                                                  -- Waiting...
    [1060] = { speed = -3, isHorz = false, instaTP = { x = 320, y = 480 } }, -- From top to center
    [1140] = { speed = 0,  laugh = true   },                                 -- Laughing animation
    [1310] = { speed = -3, isHorz = true  },                                 -- From center to left
    [1440] = { speed = 0,  noSound = true },                                 -- Never used
}
function Stare6(frame)
    -- Create sprites
    if frame == 0 and not inputted then
        boosterSprite = CreateSprite("BoosterOW/8")
        boosterSprite.ypivot = 0
        boosterSprite.MoveToAbs(-40, 240)
        boosterSprite["path"] = "BoosterOW"
        boosterSprite["speed"] = 0
        boosterSprite["isHorz"] = false
        boosterSprite.z = -1
        charaSprite = CreateSprite("CharaOW/8")
        charaSprite.ypivot = 0
        charaSprite.MoveToAbs(-40, 240)
        charaSprite["path"] = "CharaOW"
        charaSprite["speed"] = 0
        charaSprite["isHorz"] = false
        charaSprite.z = -1
        stare6Sprites = { boosterSprite, charaSprite }
        stare6Speeds = { boosterTimestamps, boosterTimestamps }
    end

    -- The sprites are only deleted when the animation is done
    if not charaSprite then
        return true
    end

    -- Handle movement for both sprites using the current count and their timestamp table
    for k, v in pairs({ stare6Count, stare6Count <= 270 and stare6Count - 10 or stare6Count }) do
        local sprite = stare6Sprites[k]
        local speedObject = stare6Speeds[k][v]
        -- If a timestamp has been found, then the sprite's behavior will change
        if speedObject then
            -- If the encounter bubble exists, delete it
            if sprite["surprise"] then
                sprite["surprise"].Remove()
                sprite["surprise"] = nil
            end
            -- Replace the sprite's speed and isHorz values with the new ones
            sprite["speed"] = speedObject.speed
            sprite["isHorz"] = speedObject.isHorz
            -- If there's a TP, teleport the sprite at the given coords
            if speedObject.instaTP then
                sprite.MoveToAbs(speedObject.instaTP.x, speedObject.instaTP.y)
            end
            -- Create encounter bubbles if needed
            if speedObject.surprise then
                -- Play the encounter bubble sound once
                if k == 2 then
                    Audio.PlaySound("BeginBattle1")
                end
                local spritename = sprite.spritename:sub(sprite.spritename:find("/[^/]*$") + 1)
                sprite.StopAnimation()
                sprite.Set(sprite["path"] .. "/" .. (math.floor(tonumber(spritename) / 4) * 4 + 1))
                local surprise = CreateSprite("Overworld/EncounterBubble" .. (k == 2 and "Geno" or ""))
                surprise.SetParent(sprite)
                surprise.SetPivot(.5, 0)
                surprise.SetAnchor(.5, 1)
                surprise.MoveTo(0, 0)
                sprite["surprise"] = surprise
            end
            -- If the sprite doesn't move in this behavior
            if sprite["speed"] == 0 then
                sprite.StopAnimation()
                -- If the sprite needs a laughing animation, use it
                if speedObject.laugh then
                    sprite.SetAnimation({ "l1", "l2", "l3" }, 1 / 8, sprite["path"])
                    NewAudio.CreateChannel("Stare")
                    NewAudio.PlaySound("Stare", "Laugh")
                -- If the sprite doesn't move, it plays the runaway sound: if noSound is true, it doesn't play it
                elseif not speedObject.noSound then
                    Audio.PlaySound("runaway")
                end
            else
                -- Delete the audio channel Stare if it exists
                if NewAudio.Exists("Stare") then
                    NewAudio.DestroyChannel("Stare")
                end
                local start = sprite["speed"] > 0 and (sprite["isHorz"] and 8 or 12) or (sprite["isHorz"] and 4 or 0)
                local tab = { }
                for i = 0, 3 do table.insert(tab, start + i) end
                sprite.SetAnimation(tab, 3 / 5 / math.abs(sprite["speed"]), sprite["path"])
            end
        end
        -- Move the sprite using its speed and isHorz values
        sprite.Move(sprite["isHorz"] and sprite["speed"] or 0, sprite["isHorz"] and 0 or sprite["speed"])
    end

    local canInput = true
    for _, v in pairs(stare6Sprites) do
        if v["speed"] ~= 0 or NewAudio.Exists("Stare") or boosterSprite["surprise"] then
            canInput = false
            break
        end
    end

    -- If no sprite is moving, the audio channel Stare doesn't exist, no encounter bubble exists and player has pressed a key, stop the event
    -- Deletes all the sprites and clean the animation up when it's done
    if (inputted and canInput) or stare6Count == 1439 then
        boosterSprite.Remove(); boosterSprite = nil
        charaSprite.Remove();   charaSprite = nil
        stare6Sprites = nil; stare6Speeds = nil
        if NewAudio.Exists("Stare") then
            NewAudio.DestroyChannel("Stare")
        end
    -- If a key is pressed while the laughing animation is ongoing, stop it
    elseif NewAudio.Exists("Stare") and (inputted or NewAudio.IsStopped("Stare")) then
        stare6Count = 1309
    -- Replace the chara sprite's timestamp table with his own when the common part is finished
    elseif stare6Count == 270 then
        stare6Speeds[2] = charaTimestamps
    -- Killing in progress
    elseif stare6Count == 1000 then
        Audio.PlaySound("hitSound")
        Misc.ShakeScreen(3)
    end

    stare6Count = stare6Count + 1

    return false
end

function Stare7(frame) DEBUG("Stare7: " .. frame) return true end
function Stare8(frame) DEBUG("Stare8: " .. frame) return true end

-- Auto
function EventPage2()
    stareShift = Event.Exists("Punder") and 0 or 2
    stareFrame = 0
    inputted = false
    currEventDone = true
    resetStareVars()
    Event.SetPage(Event.GetName(), 3)
end

-- Parallel process
function EventPage3()
    local stareID = math.floor(stareFrame / eventFrequency)
    local realStareID = stareID + stareShift
    if stareID > 0 and realStareID <= maxStares then
        currEventDone = _G["Stare" .. realStareID](stareFrame % eventFrequency)
    end

    if not inputted then
        if Input.Left == 1 or Input.Right == 1 or Input.Up == 1 or Input.Down == 1 or Input.Confirm == 1 or Input.Cancel == 1 or Input.Menu == 1 then
            inputted = true
        end
    end

    if inputted and currEventDone then
        SetGlobal("CYFOWStare", math.min(realStareID, maxStares) + 1)
        Player.CanMove(true)
        Event.SetPage(Event.GetName(), 1)
        Event.SetPage("Event1", 5)
        Event.StopCoroutine()
        return
    end

    Player.CanMove(false)
    if not inputted then
        stareFrame = stareFrame + 1
    end
end