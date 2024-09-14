pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
--inits

--globals
state="menu"
g={}
p={}
starts={}
parts={}
cam={}

function _init() 
	init_gamestate()
end

function init_menustate()
	state="menu"
end

function init_gamestate()
	state="game"
	
	init_p()
	init_stars()
	init_parts()
	
	init_cam()
end

function init_endstate()
	state="end"
end

function init_cam()
	cam.x=0
	cam.y=0
	cam.dz=32
	cam.isscroll=false
end

function init_p()
	p.x=60
	p.y=60
	p.vx=0
	p.vy=0
	p.ax=.1
	p.ay=.1
	p.w=8
	p.h=8
	p.spr=2
	p.flip=false	
	p.fuel=1000
end

function init_stars()	
	stars={}
	for i=1,64 do
		local s={}
		s.x=rnd(127)
		s.y=rnd(127)
		s.c=white
		add(stars,s)
	end
end

function init_parts()
--	parts={}
end

function get_part(x,y,vx,vy)
	local pt={}
	pt.x=x
	pt.y=y
	pt.vx=vx
	pt.vy=vy
	pt.c=yellow
	pt.life=rnd(15)
	return pt
end
-->8
--updates
function _update()
	if state=="menu" then
	 update_menustate()
	elseif state=="game" then
	 update_gamestate()
	elseif state=="end" then
	 update_endstate()
	end
end

function update_menustate()
	if(btnp(btn_o)) init_gamestate()
end

function update_gamestate()
	updt_p()
	updt_stars()
	updt_parts()
	
	updt_cam()	

	if(btnp(btn_o)) init_endstate()
end

function update_endstate()
	if(btnp(btn_o)) init_menustate()
end

function updt_p()
	if btn(btn_left) then
		p.vx-=p.ax
		p.flip=true
		add(parts,
			get_part(
				p.x+1,p.y+5,
				1,rnd(1)-.5))
	end
	if btn(btn_right) then
		p.vx+=p.ax
		p.flip=false
		add(parts,
			get_part(
				p.x+1,p.y+5,
				-1,rnd(1)-.5))
	end
	
	if btn(btn_up) then
		p.vy-=p.ay
		add(parts,
			get_part(
				p.x+1,p.y+5,
				rnd(1)-.5,1))
	end
	if btn(btn_down) then
		p.vy+=p.ay
		add(parts,
			get_part(
				p.x+1,p.y+5,
				rnd(1)-.5,-1))
	end

	if btn(btn_left)
		or btn(btn_right)
		or btn(btn_up)
		or btn(btn_down) then
		p.fuel-=1
	end	
	p.x+=p.vx
	p.y+=p.vy
end

function updt_stars()
	for s in all(stars) do
		--wrap x
		if s.x<cam.x then
			s.x=cam.x+127-rnd(abs(p.vx))
			s.y=rnd(127)+cam.y
		elseif s.x>cam.x+127 then
			s.x=cam.x+rnd((abs(p.vx)))
			s.y=rnd(127)+cam.y
		end
		
		if s.y<cam.y then
			s.x=rnd(127)+cam.x
			s.y=cam.y+127-rnd(abs(p.vy))
		elseif s.y>cam.y+127 then
			s.x=rnd(127)+cam.x
			s.y=cam.y+rnd(abs(p.vy))
		end
	end
	
	
end

function updt_parts()
	for pt in all(parts) do
		if pt.life<=0 then
			del(parts,pt)
		else
			pt.life-=1
			pt.x+=pt.vx
			pt.y+=pt.vy	
		end
	end
end

function updt_cam()
	if p.x<cam.x+cam.dz
		or p.x>cam.x+127-cam.dz
	then
		cam.isscroll=true
		cam.x+=p.vx
	end
	
	if p.y<cam.y+cam.dz
		or p.y>cam.y+127-cam.dz
	then
		cam.isscroll=true
		cam.y+=p.vy
	end
end
-->8
--draws
function _draw()
	cls()
	if state=="menu" then
	 draw_menustate()
	elseif state=="game" then
	 draw_gamestate()
	elseif state=="end" then
	 draw_endstate()
	end	
end

function draw_menustate()
	print("space",60,60)
end

function draw_gamestate()
--	camera()
	draw_stars()
	draw_pcam()
	draw_parts()
	draw_p()
	--draw_debug()
--	draw_hud()
end

function draw_endstate()
	print("end",60,60)
end

function draw_debug()
	print(state,0,0,white)
	pset(p.x,p.y,red)
	rect(
		cam.x+cam.dz,cam.y+cam.dz,
		cam.x+127-cam.dz,cam.y+127-cam.dz,
		green)
	draw_debugkeys(2,125)
end

function draw_p()
	spr(p.spr,p.x,p.y,1,1,p.flip)
end

function draw_pcam()
	camera(cam.x,cam.y)
end

function draw_stars()
	for s in all(stars) do
		if false and cam.isscroll then
			line(
				s.x,s.y,
				s.x+p.vx,s.y+p.vy,
				dark_blue)
			line(
				s.x,s.y,
				s.x+p.vx/2,s.y+p.vy/2,
				dark_grey)
		end
		
		pset(s.x,s.y,s.c)
	end
end

function draw_parts()
	for pt in all(parts) do
		pset(pt.x,pt.y,pt.c)
	end
end

function draw_hud()
	rect(
		0,0,
		10,127,
		white)
	rectfill(
		2,2+(123-123*(p.fuel/1000)),
		8,125,
		green)
end

function draw_debugkeys(x,y)
	--buttons
	if(btn(btn_left)) pset(x+0,y+1,red)
	if(btn(btn_up)) pset(x+1,y+0,green)
	if(btn(btn_down)) pset(x+1,y+1,blue)
	if(btn(btn_right)) pset(x+2,y+1,yellow)
	if(btn(btn_x)) pset(x+4,y,white)
	if(btn(btn_o)) pset(x+4,y+1,white)
end

-->8
--utils

-- btns
btn_left=0
btn_right=1
btn_up=2
btn_down=3
btn_o=4
btn_x=5

-- colors
black=0
dark_blue=1
dark_red=2
dark_green=3
brown=4
dark_grey=5
light_grey=6
white=7
red=8
orange=9
yellow=10
green=11
blue=12
grey=13
pink=14
tan=15
__gfx__
0000000057777775000dddd0000dddd0000dddd00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000007500005700d0006d00d0006d00d0006d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0070070070500507dd71110ddd71110ddd71110d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0007700070055007dd77110ddd77110ddd77110d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000700550075d6d77705d6d77705d6d77700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0070070070500507556dd655556dd655556dd6550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000750000570056770000d677500056d7000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000005777777500dd055000d00500000d55000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
