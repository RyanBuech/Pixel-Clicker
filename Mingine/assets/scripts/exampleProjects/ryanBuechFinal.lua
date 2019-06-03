
SCREEN_WIDTH = 1026
SCREEN_HEIGHT = 768
MAX_RECTS = 5
SPAWN_DELAY_MS = 1500
spawnTimer = 0.0
splashGone = false
score = 0
lives = 0
difficultyFactor = 1.1

rects = {}
tryAgainRects = {}

function addRect()
    local rect = {}
    rect.x = math.random(1, SCREEN_WIDTH - 21)
    rect.y = math.random(1, SCREEN_HEIGHT - 21)
	if rect.x < 210 and rect.y <90 then
		rect.x = math.random(210, SCREEN_WIDTH - 21)
		rect.y = math.random(90, SCREEN_HEIGHT - 21)
	end
    rect.w = 20
    rect.h = 20
    
    rect.r = math.random(0, 255)
    rect.g = math.random(0, 255)
    rect.b = math.random(0, 255)
    rect.a = 255
    
    rect.outlineOnly = math.random() > 0.65
        
    rects[#rects + 1] = rect
    
    if #rects > MAX_RECTS then
        table.remove(rects, 1)
		lives = lives - 1
    end
end

function addTryAgainRect()
    local rect = {}
    rect.x = SCREEN_WIDTH/2 - 108
    rect.y = 545
    rect.w = 200
    rect.h = 60
    
    rect.r = 127
    rect.g = 255
    rect.b = 54
    rect.a = 255
	
	tryAgainRects[#tryAgainRects + 1] = rect
end

function IsOnRect(x, y, rect)
    return IsPointInBox(x, y, rect)
end

function RemoveRectAt(x, y)
    for i = 1, #rects do
        if IsOnRect(x, y, rects[i]) then
            table.remove(rects, i)
            break
        end
    end
end

function Start()
	CreateWindow(SCREEN_WIDTH, SCREEN_HEIGHT)
    SetWindowTitle("Pixel Clicker")
	
	font = LoadFont("fonts/8_bit_pusab.ttf", 20)
	blop = LoadSound("sfx/Blop.wav")
	music = LoadMusic("music/level1.ogg") 
	
	PlayMusic(music)

	splash = {}
	splash.image = LoadImage("images/splash.png")
	splash.x = 0
	splash.y = 0
	
	background = {}
	background.image = LoadImage("images/backgroundImage.png")
	background.x = 0
	background.y = 0
	
	lose = {}
	lose.image = LoadImage("images/lose.png")
	lose.x = 0
	lose.y = 0
end

function Update()

	if not splashGone and IsMouseButtonDown(1) then
		PlaySound(blop)
		splashGone = true
		lives = 3
	end 
	
	if splashGone and lives == 0  then
		local mouseX
		local mouseY
		local count = 0
		mouseX, mouseY = GetMousePosition()
		
		if count == 0 then
			table.remove(rects, #rects)
			addTryAgainRect()
			count = count + 1
		end
		
		if IsMouseButtonDown(1) then
			for i = 1, #tryAgainRects do
				if IsOnRect(mouseX, mouseY, tryAgainRects[i]) then
					RemoveRectAt(mouseX, mouseY)
					--table.remove(rects, #rects)
					PlaySound(blop)
					splashGone = true
					lives = 3
					score = 0
					return
				end
			end
		end 
	
	end

	if splashGone and lives > 0 then
		local mouseX
		local mouseY
		mouseX, mouseY = GetMousePosition()

		spawnTimer = spawnTimer + GetFrameTime()
		
		while spawnTimer >= SPAWN_DELAY_MS do
			addRect()
			spawnTimer = spawnTimer - SPAWN_DELAY_MS
			SPAWN_DELAY_MS = SPAWN_DELAY_MS - score * difficultyFactor
			if SPAWN_DELAY_MS < 100 then
				SPAWN_DELAY_MS = 100
			end
			
		end
		
		if IsMouseButtonDown(1) then
			for i = 1, #rects do
				if IsOnRect(mouseX, mouseY, rects[i]) then
					RemoveRectAt(mouseX, mouseY)
					score = score + 1
					PlaySound(blop)
					return
				end
			end
		end 
	end
end

function Draw()
   
	if not splashGone then
		ClearScreen(0, 0, 0)
		DrawImage(splash.image, splash.x, splash.y)
	end
   
	if splashGone and lives > 0 then
	   ClearScreen(0, 0, 0)
	   DrawImage(background.image, background.x, background.y)
	   DrawText("Score: " .. score, 8, 9, font, 127, 255, 64)
	   DrawText("Lives: " .. lives, 8, 45, font, 127, 255, 64)
		
		for i = 1, #rects do
			local r = rects[i]
			SetDrawColor(r.r, r.g, r.b, r.a)
			if r.outlineOnly then
				DrawRect(r.x, r.y, r.w, r.h)
			else
				FillRect(r.x, r.y, r.w, r.h)
			end
		end
	end
	if splashGone and lives == 0  then 
		ClearScreen(0, 0, 0)		
		SPAWN_DELAY_MS = 1500
				
		DrawImage(lose.image, lose.x, lose.y)
		DrawText("Score: " .. score, SCREEN_WIDTH/2 - 80, SCREEN_HEIGHT/2 -40, font, 127, 255, 64)
	    DrawText("You ran out of lives!",SCREEN_WIDTH/2 - 180, SCREEN_HEIGHT/2 -80, font, 127, 255, 64)
		DrawText("Try again?",SCREEN_WIDTH/2 - 100, 560, font, 127, 255, 64)
		
		for i = 1, #tryAgainRects do
			local r = tryAgainRects[i]
			SetDrawColor(r.r, r.g, r.b, r.a)
			DrawRect(r.x, r.y, r.w, r.h)
		end
	end	
end