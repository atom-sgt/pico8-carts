pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
--init
------

--globals
anims={
	idle={fr=1,2},
	move={fr=5,3,4},
}

f=0--frame

function _init() 
	init_player()
end

function init_player()
	p = {
		x=32,y=	32,--position
		offx=1,offy=0,
		w=6,h=8,--dimensions
		vx=0,vy=0,--velocity
		mvx=5,mvy=5,--max velocity
		ax=0.5,ay=0.5,--acceleration
		dirx=1,diry=1,--direction
		state="idle",
	}
end
-->8
--update
--------

function _update()
	f = (f+1)%30
	update_player()
	if(btn(btn_x))then
		camera(p.x,p.y)
	end
end

function update_player()
	update_player_velocity()
	update_player_position()
	
	-- state
	if p.vx == 0 then
		p.state = "idle"
	else
		p.state = "move"
	end
end

function update_player_velocity()
	-- x accel
	if btn(btn_left)
		or btn(btn_right)
	then
		if btn(btn_left) then
			p.dirx=-1
		end
		if btn(btn_right) then
			p.dirx=1
		end
		
		p.vx += p.ax * p.dirx
	end
	
	--clamp
	p.vx = mid(p.mvx,-p.mvx,p.vx)
end

function update_player_position()
	-- x pos
	local newx = p.x + p.vx
	
	-- collision
	if isrectinmap(
		newx+p.offx,
		p.y+p.offy,
		p.w,
		p.h)
	then
		-- bounce if fast
		if abs(p.vx) > 2
		then
			--p.vx = -p.vx*0.25
			p.vx = 0
		else
			p.vx = 0
		end
		
		--close gap
		p.x = resolvex()
	else
		p.x = newx
	end
		
	if abs(p.vx) <= 0.25
	then
		p.vx = 0
	end
end

function resolvex()
	local step = 0
	local dirx = sgn(p.vx)
	
	while step+1 < abs(p.vx) do
		-- step in direction
		local tryx = p.x + dirx * step+1
		
		if isrectinmap(
			tryx+p.offx,
			p.y+p.offy,
			p.w,
			p.h)
		then
			--stop if next step is collide
			break
		else
			--step if no collide
			step = step + 1
		end
	end
	
	return p.x + dirx*step
end
-->8
--draw
------

function _draw()
	cls()
	draw_map()
	draw_player()
 draw_debug()
end

function draw_player()
	if p.state=="move" then
		local af = 
		flr((f/anims.move.fr))%#anims.move
		spr(
			anims.move[af+1],
			p.x,p.y)
	else
		spr(2,p.x,p.y)
	end
end

function draw_map()
	map()
end

function draw_debug()
	draw_debug_keys(125,0)
	draw_hitbox()	
	print(p.x)
end

function draw_debug_keys(x,y)
	--buttons
	if(btn(btn_left)) pset(x+0,y+1,red)
	if(btn(btn_up)) pset(x+1,y+0,green)
	if(btn(btn_down)) pset(x+1,y+1,blue)
	if(btn(btn_right)) pset(x+2,y+1,yellow)
end

function draw_hitbox()
 	rect(
			p.x+p.offx,
			p.y+p.offy,
			p.x+p.w,
			p.y+p.h)
end
-->8
--utils
-------

--collision
function isinmap (x,y)	
	return fget(
		mget(
			flr(x/8),
			flr(y/8)),
		f_solid)
end

function isrectinmap(x,y,w,h)
	return isinmap(x,y)
		or isinmap(x+w,y)
		or isinmap(x,y+h)
		or isinmap(x+w,y+h)
end

function isinrect(x,y,rx,ry,rw,rh)
	return (x>=rx and x<=rx+rw)
		and (y>=ry and y<=ry+rh)
end

function isrectinrect(x1,y1,w1,h1,x2,y2,w2,h2)
	return (x1<x2+w2)
		and (x1+w1>x2)
		and (y1<y2+h2)
		and (y1+h1>y2)
end

function isincirc(x,y,cx,cy,cr)
	return dist(x,y,cx,cy) < cr
end

function iscircincirc(cx1,cy1,cr1,cx2,cy2,cr2)
	return dist(cx1,cy1,cx2,cy2) <= cr1+cr2
end

function dist(x1,y1,x2,y2)
	return sqrt((x2-x1)*(x2-x1)+(y2-y1)*(y2-y1))
end

function avg(n1,n2)
	return (n1+n2)/2
end

function int(n)
	return flr(n+0.5)
end
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

-- tile flags
f_solid=0
__gfx__
00000000577777750777777007777770077777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000750000570700007007000070070000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700705005070700007007000070070000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000700550070777777007777770077777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000700550070777777007777770077777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700705005070777777007777770077777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000750000570770077007700770077007700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000577777750770077007700000000007700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0100000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0100000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0100000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0100000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0100000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0100000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0100000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0100000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0100000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0100000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0100000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0100000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
