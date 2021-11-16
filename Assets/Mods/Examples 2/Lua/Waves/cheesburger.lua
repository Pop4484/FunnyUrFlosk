-- You've seen this one in the trailer (if you've seen the trailer).
spawntimer = 0
bullets = {}
yOffset = 180
mult = 0.5

function Update()
    spawntimer = spawntimer + 1
    if(spawntimer % 30 == 0) then
        local numbullets = 20
        for i=1,numbullets+1 do
            local bullet = CreateProjectile('hamborger', 0, yOffset)
            bullet.SetVar('timer', 0)
            bullet.SetVar('offset', math.pi * 2 * i / numbullets)
            bullet.SetVar('negmult', mult)
            bullet.SetVar('lerp', 0)
            table.insert(bullets, bullet)
        end
        mult = mult + 0.05
    end

    for i=1,#bullets do
        local bullet = bullets[i]
        local timer = bullet.GetVar('timer')
        local offset = bullet.GetVar('offset')
        local lerp = bullet.GetVar('lerp')
        local neg = 10
        local posx = (700*lerp)*math.sin(timer*bullet.GetVar('negmult') + offset)
        local posy = (700*lerp)*math.cos(timer + offset) + yOffset - lerp*50
        bullet.MoveTo(posx, posy)
        bullet.SetVar('timer', timer + 100/40)
        lerp = lerp + 1 / 90
        if lerp > 40.0 then
            lerp = 40.0
        end
        bullet.SetVar('lerp', lerp)
    end
end
function OnHit()
    Player.Hurt(5,0)
end