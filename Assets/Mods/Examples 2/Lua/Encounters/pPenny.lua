-- A basic encounter script skeleton you can copy and modify for your own creations.

music = "battlelol" --Either OGG or WAV. Extension is added automatically. Uncomment for custom music.
encountertext = "Proto Penny blocks your way!" --Modify as necessary. It will only be read out in the action select screen.
nextwaves = {"bullettest_chaserorb"}
wavetimer = 10
arenasize = {155, 130}

enemies = {
"protopenny"
}

enemypositions = {
{0, 0}
}

-- A custom list with attacks to choose from. Actual selection happens in EnemyDialogueEnding(). Put here in case you want to use it.
possible_attacks = {"bullettest_bouncy", "bullettest_chaserorb", "bullettest_touhou"}

function EncounterStarting()
    -- If you want to change the game state immediately, this is the place.
    -- Pause the music to start it when you need to start it.
    Audio.Pause()
    -- Intro text!
    enemies[1]["currentdialogue"] = {"[voice:pPenny]I'm gonna \nstop you\nright \nthere!", "[noskip][func:LaunchMusic][func:State, ACTIONSELECT][next]"}
    -- Starts the battle with set text
    State("ENEMYDIALOGUE")
end

function EnemyDialogueStarting()
    -- Good location for setting monster dialogue depending on how the battle is going.
end

function EnemyDialogueEnding()
    -- Good location to fill the 'nextwaves' table with the attacks you want to have simultaneously.
    nextwaves = { possible_attacks[math.random(#possible_attacks)] }
end

function DefenseEnding() --This built-in function fires after the defense round ends.
    encountertext = RandomEncounterText() --This built-in function gets a random encounter text from a random enemy.
end

function HandleSpare()
    State("ENEMYDIALOGUE")
end

function HandleItem(ItemID)
    BattleDialog({"Selected item " .. ItemID .. "."})
end