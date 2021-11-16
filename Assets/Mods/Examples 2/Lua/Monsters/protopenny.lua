-- A basic monster script skeleton you can copy and modify for your own creations.
comments = {"Damn i wonder what this is.", "what.", "hi"}
commands = {"Act 1", "Act 2", "Act 3"}
randomdialogue = {"[voice:pPenny]Not bad.", "[voice:pPenny]try again.", "[voice:pPenny]pauhi be like."}

sprite = "hi" --Always PNG. Extension is added automatically.
name = "Proto Penny"
hp = 1000
atk = 1
def = 10
check = ""
dialogbubble = "right" -- See documentation for what bubbles you have available.
canspare = false
cancheck = true
xp = 500000

-- Happens after the slash animation but before 
function HandleAttack(attackstatus)
    if attackstatus == -1 then
        -- player pressed fight but didn't press Z afterwards
    else
        -- player did actually attack
    end
end

function LaunchMusic()
    Audio.Unpause()
end
 
-- This handles the commands; all-caps versions of the commands list you have above.
function HandleCustomCommand(command)
    if command == "ACT 1" then
        currentdialogue = {"Selected\nAct 1."}
    elseif command == "ACT 2" then
        currentdialogue = {"Selected\nAct 2."}
    elseif command == "ACT 3" then
        currentdialogue = {"Selected\nAct 3."}
    end
    BattleDialog({"You selected " .. command .. "."})
end