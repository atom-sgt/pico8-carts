pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
--init
p={}
b={}
ball={}
score=0
state="menu"
function _init()
	init_menustate()
end

function init_menustate()
	state="menu"
end

function init_gamestate()
	state="game"
	reset_player()
	reset_blocks()
	reset_ball()
	reset_score()
end

function init_endstate()
	state="end"
end

function reset_player()
	p.w=16
	p.h=1
	p.x=56
	p.y=120
	p.vx=2
end

function reset_blocks()
	for i=0,15 do
		for j=0,3 do
			local bl={
				w=12,
				h=4,
				x=i*13,
				y=j*5+8,
				c=red
			}
			add(b,bl)
		end
	end
end

function reset_ball()
	ball={
		x=64,
		y=118,
		w=2,
		h=2,
		c=green,
		vx=0,
		vy=0
	}
end

function reset_score()
	score=0
end
-->8
--update
function _update()
	if (state=="menu") updt_menustate()
	if (state=="game") updt_gamestate()
	if (state=="end") updt_endstate()
end

function updt_menustate()
	if(btnp(btn_x)) init_gamestate()
end

function updt_gamestate()
	updt_player()
	updt_ball()
end

function updt_endstate()
	if (btnp(btn_x)) init_menustate()
end

function updt_player()
	if(btn(0)) then
		p.x -= p.vx
	end
	if(btn(1)) then
		p.x += p.vx
	end

	p.x = mid(0,p.x,128)
end

function updt_ball()
	if btnp(btn_x) 
		and ball.vy==0
	then
		ball.vx=0
		ball.vy=-2
	end
	if btnp(btn_o)
	then
		ball.vy=0
	end
	
	bounds_check()	
	player_check()
	block_check()
	
	ball.x+=ball.vx
	ball.y+=ball.vy
end

function bounds_check()
	if ball.x > 128
		or ball.x < 0
	then
		ball.vx*=-1
	end
	
	if ball.y < 0
	then
		ball.vy*=-1
	end
	
	if ball.y > 128
	then
		init_endstate()
	end
end

function player_check()
	if islineinline(
		ball.x,
		ball.y,
		ball.x+ball.vx,
		ball.y+ball.vy,
		p.x,
		p.y,
		p.x+p.w,
		p.y)
	then
		player_hit()
	end
end

function player_hit()
	local speed=2
	local diff=abs(p.x-ball.x)
	local perc=diff/p.w
	local v=speed*(perc*2-1)
	ball.vx=v
	ball.vy*=-1
	sfx(2)
end

function block_check()
	for bl in all(b) do
		if isinrect(
			ball.x,
			ball.y+ball.vy,
			bl.x,
			bl.y,
			bl.w,
			bl.h)
		then
			ball.vy*=-1
			block_hit(bl)
			break
		end
		if isinrect(
			ball.x+ball.vx,
			ball.y,
			bl.x,
			bl.y,
			bl.w,
			bl.h)
		then
			ball.vx*=-1
			block_hit(bl)
			break
		end
	end
end

function block_hit(bl)
	del(b,bl)
	score+=100
	sfx(1)
end
-->8
--draw
function _draw()
	cls()
	if (state=="menu") draw_menustate()
	if (state=="game") draw_gamestate()
	if (state=="end") draw_endstate()
end

function draw_menustate()
	print("menu")
end

function draw_gamestate()
	draw_player()
	draw_blocks()
	draw_ball()
	draw_hud()
end

function draw_endstate()
	print("end")
end

function draw_player()
	rectfill(
		p.x,
		p.y,
		p.x+p.w-1,
		p.y+p.h-1,
		7)
end

function draw_blocks()
	for bl in all(b) do
		rectfill(
		bl.x,
		bl.y,
		bl.x+bl.w-1,
		bl.y+bl.h-1,
		bl.c)
	end
end

function draw_ball()
	pset(ball.x,ball.y,ball.c)
end

function draw_hud()
	print(score,0,0,white)
end
-->8
--utils
-------

--collision
	function isinline(px,py,qx,qy,rx,ry)
		return qx <= max(px,rx)
			and qx >= min(px,rx)
			and qy <= max(py,ry)
			and qy >= min(py,ry)
	end
	
	function islineinline(
		p1x,p1y,
		q1x,q1y,
		p2x,p2y,
		q2x,q2y)
			o1=orient(
				p1x,p1y,
				q1x,q1y,
				p2x,p2y)
			o2=orient(
				p1x,p1y,
				q1x,q1y,
				q2x,q2y)
			o3=orient(
				p2x,p2y,
				q2x,q2y,
				p1x,p1y)
			o4=orient(
				p2x,p2y,
				q2x,q2y,
				q1x,q1y)
			
			if o1!=o2
				and o3 != o4
			then
				return true
			end
			
			if o1==o
				and isinline(p1x,p1y,p2x,p2y,q1x,q1y)
			then
				return true
			end
			if o2==o
				and isinline(p1x,p1y,q2x,q2y,q1x,q1y)
			then
				return true
			end
			if o3==o
				and isinline(p2x,p2y,p1x,p1y,q2x,q2y)
			then
				return true
			end
			if o4==o
				and isinline(p2x,p2y,q1x,q1y,q2x,q2y)
			then
				return true
			end
			
			return false
	end
	
	collin=0
	cw=1
	ccw=2
	function orient(
		px,py,
		qx,qy,
		rx,ry)
		local val = (qy-py) * (rx-qx)
			- (qx-px) * (ry-qy)
		
		if (val==0) return collin
		if val > 0 then
			return cw
		else
			return ccw
		end
	end

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
00000000666600666660666606666606000606666606000606666600000000000000000000000000000000000000000000000000000000000000000000000000
00000000600600600060600006000606000606000606000600060000000000000000000000000000000000000000000000000000000000000000000000000000
00700700666660666660666606666606666606000606000600060000000000000000000000000000000000000000000000000000000000000000000000000000
00077000600060600600600006000606006006000606000600060000000000000000000000000000000000000000000000000000000000000000000000000000
00077000600060600600600006000606006006000606000600060000000000000000000000000000000000000000000000000000000000000000000000000000
00700700666660600600666606000606006006666606666600060000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100001e5501d5501c5501c5501b5501a55019550185501755016550145501255011550105500e5500d5000b500095000650003500005000550005500005000000000000000000000000000000000000000000
000100000a3400e3400f3401134012340133301333013330113300f3300d3200b3200832005320023200131000010000000000000000000000000000000000000000000000000000000000000000000000000000
00010000123501635017350193501a3501c3501f3501f350000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
