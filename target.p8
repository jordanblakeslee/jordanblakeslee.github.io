pico-8 cartridge // http://www.pico-8.com
version 42
__lua__

chomp_x = 10
chomp_y = 10
chomp_s = 0
chomp_c = 12
mouse_x = 0
mouse_y = 0

speed = 2
frame = 0
cooldown = 0
total_score = 0
score = 0
shots = 0
hits = 0
targets = {}
level = 0
high_score = 0



function prep_level(l)
	targets = {}
	for i = 0,6 do
		for o = 1,6 do
			local ori = flr(rnd(2))
			local t = flr(rnd(3480-l*600))+120
			local tar = 38
			if l == 4 then
				tar = 102
			end
			local new_target = {sprite=tar,ori=ori,x=i*16+8,y=o*16+9,t_start=t,t_end=t+150}
			add(targets,new_target)
		end
	end
	level += 1
	frame = 0
	hits = 0
	shots = 0	
end


function _init()
	cartdata("chomper")
	high_score = dget(0)
	prep_level(0)
 --activate this
 --to reset high score
	--dset(0,0)
end

poke(0x5f2d,1)

function mouse_pos()
	mouse_x = stat(32)-1
	mouse_y = stat(33)-1
end

function move_chomp()
	if btn(0) then
	 chomp_x += -1
	end
	if btn(1) then
		chomp_x += 1
	end
	if btn(2) then
		chomp_y += -1
	end
	if btn(3) then
	 chomp_y += 1
	end
end

function erase()
	for v in all(targets) do
		if stat(32) > v.x-1 and
		stat(32) < v.x+16 then
			if	stat(33) > v.y-1 and
			stat(33) < v.y+16 then
				del(targets,v)
			end
		end
	end
	
end

function hit()
	local index = pget(stat(32),stat(33))
	local hot = false
	if index == 12 then
		score += 20
		hot = true
	elseif index == 1 then
		score += 10
		hot = true
	elseif index == 6 then
		score += 6
		hot = true
	elseif index == 5 then
		score += 3
		hot = true
	elseif index == 13 then
		score += 1
		hot = true
	end
	if hot == true then
		hits += 1
		erase()
	end
	
end

function click()
	if stat(34) == 1 and frame < 3840-(level-1)*600 then
		hit()
		cooldown = 10
		shots += 1
	end
	--print pget(
end

function _update60()
	frame += 1
	if cooldown > 0 then
		cooldown += -1
	end
	if (frame%speed == 0) == false then
		return
	end
	mouse_pos()
	move_chomp()
	
	if frame > 3960 - (level - 1) * 600 then
	
		if frame > 4260 - (level - 1) * 600 then
			if score > 0 and score > 10 then
				score += -10
				total_score += 10
			end
			if score < 11 and score > 0 then
				score += -1
				total_score += 1
			end
		end
	
		if frame == 4080 - (level - 1) * 600 then
			if hits == shots then
				score = score * 2
			elseif hits / shots > 0.89 then
				score = flr(score * 1.5)
			elseif hits / shots > 0.79 then
				score = flr(score * 1.2)
			end
		end

		if frame == 4140 - (level - 1) * 600 then
			if hits == 42 then
				score = score * 2
			end
		end	
	
		if frame > 4800 - (level - 1) * 600 and level < 5 then
			prep_level(level)		
		end
	end
end

function oob()
	if mouse_x < -2 then
		spr(10, -4, 64)
	end
	if mouse_x > 127 then
		spr(10, 127, 64)
	end
	if mouse_y < -2 then
		spr(10, 64, -4)
	end
	if mouse_y > 127 then
		spr(10, 64, 127)
	end
end

function _draw()
	cls()
	if frame < 120 then
		print("level "..level, 30, 52, 7)
	end
	print("total score: "..total_score, 5, 3, 7)
	print("level score: "..score,5,10,7)
	print("high score",80,3,7)
	print("  "..high_score,80,10,7)
	mouse_pos()

	for s in all(targets) do
		if frame > s.t_start and frame < s.t_end then
			if s.ori==1 then
				if frame < s.t_start+6 then
					spr(s.sprite-6,s.x,s.y,2,2)
				elseif frame < s.t_start+11 then
					spr(s.sprite-4,s.x,s.y,2,2)
				elseif frame < s.t_start+16 then
					spr(s.sprite-2,s.x,s.y,2,2)
				elseif frame < s.t_start+134 then
					spr(s.sprite, s.x, s.y, 2, 2)
				elseif frame < s.t_start+139 then
					spr(s.sprite-2,s.x,s.y,2,2)
				elseif frame < s.t_start+144 then
					spr(s.sprite-4,s.x,s.y,2,2)
				else			
					spr(s.sprite-6,s.x,s.y,2,2)
				end
			else
				if frame < s.t_start+6 then
					spr(s.sprite+6,s.x,s.y,2,2)
				elseif frame < s.t_start+11 then
					spr(s.sprite+4,s.x,s.y,2,2)
				elseif frame < s.t_start+16 then
					spr(s.sprite+2,s.x,s.y,2,2)
				elseif frame < s.t_start+134 then
					spr(s.sprite, s.x, s.y, 2, 2)
				elseif frame < s.t_start+139 then
					spr(s.sprite+2,s.x,s.y,2,2)
				elseif frame < s.t_start+144 then
					spr(s.sprite+4,s.x,s.y,2,2)
				else			
					spr(s.sprite+6,s.x,s.y,2,2)
				end
			end
		end
	end
	if frame < 3840 - (level - 1) * 600 and frame > 120 then
		rect(23,16,24,128,4)
		rect(39,16,40,128,4)
		rect(55,16,56,128,4)
		rect(71,16,72,128,4)
		rect(87,16,88,128,4)
		rect(103,16,104,128,4)
	end
	spr(14,-8,16,2,16)
	spr(14,120,16,2,16)
	spr(12,-8,16,2,1)	
	spr(12,8,16,2,1)
	spr(12,24,16,2,1)
	spr(12,40,16,2,1)
	spr(12,56,16,2,1)
	spr(12,72,16,2,1)
	spr(12,88,16,2,1)
	spr(12,104,16,2,1)
	spr(12,120,16,2,1)


	rectfill(0,122,128,128,4)	
	spr(0, mouse_x, mouse_y)
	oob()

	if cooldown == 0 then
		click()
	end

	if frame > 4802 - (level - 1) * 600 then
		print("game over", 35, 34, 10)
		if total_score > high_score then
			print("new high score!!",30,42,10)
			dset(0,total_score)
			if high_score < total_score then
				high_score += 1
			end
		end
		print("start again?",30,94,12)
		print("yes    no",35,110,10)
		--spr(64,30,102,2,2)
		--spr(66,48,102,2,2)
		if mouse_x > 30 and mouse_x < 48 and
		mouse_y > 105 and mouse_y < 117 then
		rect(32,107,48,117,6)
			if stat(34) == 1 then
				total_score = 0
				score = 0
				shots = 0
				hits = 0
				targets = {}
				level = 0
				prep_level(0)
			end
		end
		if mouse_x > 58 and mouse_x < 72 and
		mouse_y > 105 and mouse_y < 117 then
		rect(60,107,72,117,6)
			if stat(34) == 1 then
				stop()				
			end
		end
	end
	
	if frame > 3840 - (level - 1) * 600 then
		print("level clear", 30, 52, 7)
	end
	if frame > 3960 - (level - 1) * 600 then
		print("score:", 25, 62, 7)
	end
	if frame > 3990 - (level - 1) * 600 then
		print(score, 64, 62, 7)
	end
	if frame > 4020 - (level - 1) * 600 then
		print("accuracy:", 25, 70, 7)
	end
	if frame > 4050 - (level - 1) * 600 then
		print(hits.."/"..shots.."  "..flr(hits / shots * 100).."%", 64, 70, 7)
	end
	if frame > 4080 - (level - 1) * 600 then
		local bonus = "none"
		if hits == shots then
			bonus = "x 2"
		elseif hits / shots > 0.89 then
			bonus = "x 1.5"
		elseif hits / shots > 0.79 then
			bonus = "x 1.2"
		end
		print("accuracy bonus: "..bonus, 25, 78, 12)
	end
	if frame > 4140 - (level - 1) * 600 then
		if hits == 42 then
			print("perfection bonus: x 2", 25, 86, 12)
		end
	end
			
end
__gfx__
070000008282888ee88828280000000000000000000000000000055555500000000000000000000077777000000000008282888ee88828288282888ee8882828
70700000288828e88e828882000000000000000000000000000555555555500000000000000000007777700000000000288828e88e828882288828e88e828882
07000000288828e88e828882000000000005555555555000005555555555550000055555555550007777700000000000288828e88e828882288828e88e828882
000000008282888ee88828280000000000555555555555000555566666655550005555555555550077777000000000008282888ee88828288282888ee8882828
000000008282888ee888282800000000055556666665555005556666666655500555566666655550777770000000000022222222222222228282888ee8882828
0000000022222222222222220000000005556666666655505556661111666555055566666666555000000000000000002222222222222222288828e88e828882
0000000022222222222222220000000055566611116665555556611111166555555666111166655500000000000000002222222222222222288828e88e828882
0000000020022002200220020000000055566111111665555556611cc11665555556611111166555000000000000000020022002200220028282888ee8882828
000000000000000000000000000000005556611cc11665555556611cc11665555556611cc116655500000000000000005556611cc11665558282888ee8882828
000044444440000000000000000000005556611cc116655555566111111665555556611cc116655500000000000000005556611111166555288828e88e828882
0000404440400000000000000000000055566111111665555556661111666555555661111116655500000000000000005556661111666555288828e88e828882
00044404044400000000000000000000555666111166655505556666666655505556661111666555000000000000000005556666666655508282888ee8882828
04444444444444000000000000000000055566666666555005555666666555500555666666665550000000000000000005555666666555508282888ee8882828
0400404040400400000000000000000005555666666555500055555555555500055556666665555000000000000000000055555555555500288828e88e828882
4000404040400040000000000000000000555555555555000005555555555000005555555555550000000000000000000005555555555000288828e88e828882
40040040400400400000000000000000000555555555500000000555555000000005555555555000000000000000000000000555555000008282888ee8882828
0000000000000d0000000000000ddd00000000dddddd000000000dddddd000000000dddddd00000000ddd0000000000000d00000000000008282888ee8882828
000000000000ddd00000000000ddddd00000dddddddddd00000dddddddddd00000dddddddddd00000ddddd00000000000ddd000000000000288828e88e828882
00000000000ddddd000000000ddddddd000dddddddddddd000dddddddddddd000dddddddddddd000ddddddd000000000ddddd00000000000288828e88e828882
00000000000dd5dd000000000dd555dd00dddd555555dddd0dddd555555dddd0dddd555555dddd00dd555dd000000000dd5dd000000000008282888ee8882828
00000000000d555d000000000d55555d00ddd55555555ddd0ddd55555555ddd0ddd55555555ddd00d55555d000000000d555d000000000008282888ee8882828
00000000000d565d000000000d56665d00dd5556666555ddddd5556666555ddddd5556666555dd00d56665d000000000d565d00000000000288828e88e828882
00000000000d565d000000000d56665d00dd5566666655ddddd5566666655ddddd5566666655dd00d56665d000000000d565d00000000000288828e88e828882
00000000000d565d000000000d56165d00dd5566116655ddddd5566116655ddddd5566116655dd00d56165d000000000d565d000000000008282888ee8882828
00000000000d565d000000000d56165d00dd5566116655ddddd5566116655ddddd5566116655dd00d56165d000000000d565d000000000008282888ee8882828
00000000000d565d000000000d56665d00dd5566666655ddddd5566666655ddddd5566666655dd00d56665d000000000d565d00000000000288828e88e828882
00000000000d565d000000000d56665d00dd5556666555ddddd5556666555ddddd5556666555dd00d56665d000000000d565d00000000000288828e88e828882
00000000000d555d000000000d55555d00ddd55555555ddd0ddd55555555ddd0ddd55555555ddd00d55555d000000000d555d000000000008282888ee8882828
00000000000dd5dd000000000dd555dd00dddd555555dddd0dddd555555dddd0dddd555555dddd00dd555dd000000000dd5dd000000000008282888ee8882828
00000000000ddddd000000000ddddddd000dddddddddddd000dddddddddddd000dddddddddddd000ddddddd000000000ddddd00000000000288828e88e828882
000000000000ddd00000000000ddddd00000dddddddddd00000dddddddddd00000dddddddddd00000ddddd00000000000ddd000000000000288828e88e828882
0000000000000d0000000000000ddd00000000dddddd000000000dddddd000000000dddddd00000000ddd0000000000000d00000000000008282888ee8882828
00000000000000000000000000000000000000007700077000000000770007700000000077000770000000007700077000000000000000008282888ee8882828
0000000000000000000000000000000000000000077077000000000007707700000000000770770000000000077077000000000000000000288828e88e828882
3333333333333333888888888888888800000000007770000000000000777000000000000077700000000000007770000000000000000000288828e88e828882
33333333333333338888888888888888000000000044070000000000004407000000000000440700000000000044070000000000000000008282888ee8882828
33333333333333338888888888888888000000000044444000000000004444400000000000444440000000000044444000000000000000008282888ee8882828
3303030003000333888800880008888800000000004444400000000000444440000000000044444000000000004444400000000000000000288828e88e828882
3303030333033333888808080808888800000000000440000000000000044000000000000004400000000000000440000000000000000000288828e88e828882
33000300330003338888080808088888000000000004400000000000000440000000000000044000000000000004400000000000000000008282888ee8882828
33303303333303338888080808088888007044444444440000000004444444000070444444444400007044444444440000000000000000008282888ee8882828
3330330003000333888808080008888800744444444444000070444444444400007444444444440000744444444444000000000000000000288828e88e828882
3333333333333333888888888888888800044444444444000074444444444400000444444444440000044444444444000000000000000000288828e88e828882
33333333333333338888888888888888000444444444440000044444444444000004444444444400000444444444440000000000000000008282888ee8882828
33333333333333338888888888888888000044444444040000004444444404400444444444440440044444444444040000000000000000008282888ee8882828
3333333333333333888888888888888800004000000404000000444444044040000044000004404000004400000404000000000000000000288828e88e828882
0000000000000000000000000000000000004000000404000000400000004040004440000000404000444000000404000000000000000000288828e88e828882
00000000000000000000000000000000000040000004040000004000000040000000000000004000000000000004040000000000000000008282888ee8882828
00000000000005000000000000055500000000555555000000000555555000000000555555000000005550000000000000500000000000008282888ee8882828
0000000000005550000000000055555000005555555555000005555555555000005555555555000005555500000000000555000000000000288828e88e828882
0000000000055555000000000555555500055555555555500055555555555500055555555555500055555550000000005555500000000000288828e88e828882
00000000000556550000000005566655005555666666555505555666666555505555666666555500556665500000000055655000000000008282888ee8882828
00000000000566650000000005666665005556666666655505556666666655505556666666655500566666500000000056665000000000008282888ee8882828
0000000000056165000000000561116500556661111666555556661111666555556661111666550056111650000000005616500000000000288828e88e828882
0000000000056165000000000561116500556611111166555556611111166555556611111166550056111650000000005616500000000000288828e88e828882
0000000000056165000000000561c16500556611cc1166555556611cc1166555556611cc11665500561c16500000000056165000000000008282888ee8882828
0000000000056165000000000561c16500556611cc1166555556611cc1166555556611cc11665500561c16500000000056165000000000008282888ee8882828
0000000000056165000000000561116500556611111166555556611111166555556611111166550056111650000000005616500000000000288828e88e828882
0000000000056165000000000561116500556661111666555556661111666555556661111666550056111650000000005616500000000000288828e88e828882
00000000000566650000000005666665005556666666655505556666666655505556666666655500566666500000000056665000000000008282888ee8882828
00000000000556550000000005566655005555666666555505555666666555505555666666555500556665500000000055655000000000008282888ee8882828
0000000000055555000000000555555500055555555555500055555555555500055555555555500055555550000000005555500000000000288828e88e828882
0000000000005550000000000055555000005555555555000005555555555000005555555555000005555500000000000555000000000000288828e88e828882
00000000000005000000000000055500000000555555000000000555555000000000555555000000005550000000000000500000000000008282888ee8882828
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008282888ee8882828
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000288828e88e828882
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000288828e88e828882
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008282888ee8882828
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008282888ee8882828
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000288828e88e828882
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000288828e88e828882
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008282888ee8882828
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008282888ee8882828
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000288828e88e828882
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000288828e88e828882
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008282888ee8882828
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008282888ee8882828
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000288828e88e828882
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000288828e88e828882
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008282888ee8882828
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008282888ee8882828
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000288828e88e828882
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000288828e88e828882
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008282888ee8882828
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008282888ee8882828
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000288828e88e828882
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000288828e88e828882
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008282888ee8882828
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008282888ee8882828
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000288828e88e828882
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000288828e88e828882
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008282888ee8882828
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008282888ee8882828
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000288828e88e828882
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000288828e88e828882
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008282888ee8882828
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008282888ee8882828
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000288828e88e828882
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000288828e88e828882
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008282888ee8882828
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008282888ee8882828
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000288828e88e828882
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000288828e88e828882
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008282888ee8882828
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008282888ee8882828
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000288828e88e828882
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000288828e88e828882
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008282888ee8882828
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008282888ee8882828
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000288828e88e828882
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000288828e88e828882
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008282888ee8882828
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008282888ee8882828
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000288828e88e828882
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000288828e88e828882
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008282888ee8882828
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008282888ee8882828
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000288828e88e828882
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000288828e88e828882
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008282888ee8882828
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008282888ee8882828
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000288828e88e828882
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000288828e88e828882
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008282888ee8882828
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008282888ee8882828
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000288828e88e828882
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000288828e88e828882
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008282888ee8882828