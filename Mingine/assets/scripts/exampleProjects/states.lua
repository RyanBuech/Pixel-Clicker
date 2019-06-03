dofile(scriptDirectory .. "core/stateMachine.lua")
dofile(scriptDirectory .. "core/steering.lua")

SCREEN_WIDTH = 1280
SCREEN_HEIGHT = 720

MAX_ACCELERATION = 0.5 -- how fast can the agent change direction and speed?

CHASE_START_DISTANCE = 200
CHASE_END_DISTANCE = 300

--------------------------------------------
-- agent state behaviors
--------------------------------------------
function GetDistanceToPlayer(agent)
    toPlayer = {}
    toPlayer.x, toPlayer.y = VectorTo(agent.x, agent.y, player.x, player.y)
    
    return Magnitude(toPlayer.x, toPlayer.y)
end

function GetDistanceToAgent(cat)
	toAgent = {}
	toAgent.x, toAgent.y = VectorTo(cat.x, cat.y, agent.x, agent.y)

	return Magnitude(toAgent.x, toAgent.y)
end

--------------------------------------------
-- agent state behaviors
--------------------------------------------

function WanderEnter(agent)
    agent.r = 255
    agent.g = 255
    agent.b = 255
    
    MAX_ACCELERATION = 0.5
end

function CatWanderEnter(cat)
	
	MAX_ACCELERATION = 0.5
end

function WanderUpdate(agent)
    local x, y = Wander(agent)
    x, y = Normalize(x, y)
    agent.acceleration.x, agent.acceleration.y = Scale(x, y, MAX_ACCELERATION)
        
    TurnTo(agent, agent.velocity)
    UpdateEntity(agent)
    
    -- confine agent to visible screen
    if agent.x > SCREEN_WIDTH then agent.x = 0 end
    if agent.y > SCREEN_HEIGHT then agent.y = 0 end
    if agent.x < 0 then agent.x = SCREEN_WIDTH end
    if agent.y < 0 then agent.y = SCREEN_HEIGHT end
    
    --transitions
    if GetDistanceToPlayer(agent) < CHASE_START_DISTANCE then 
        EnterState(agent, chaseState)
		EnterState(cat, fleeState)
    end
end

function CatWanderUpdate(cat)
    local x, y = Wander(cat)
    x, y = Normalize(x, y)
    cat.acceleration.x, cat.acceleration.y = Scale(x, y, MAX_ACCELERATION)
        
    TurnTo(cat, cat.velocity)
    UpdateEntity(cat)
    
    -- confine agent to visible screen
    if cat.x > SCREEN_WIDTH then cat.x = 0 end
    if cat.y > SCREEN_HEIGHT then cat.y = 0 end
    if cat.x < 0 then cat.x = SCREEN_WIDTH end
    if cat.y < 0 then cat.y = SCREEN_HEIGHT end
    
    --transitions
    if GetDistanceToAgent(cat) < CHASE_START_DISTANCE then 
        EnterState(cat, fleeState)
    end
end

function WanderExit(agent)
    
end

function CatWanderExit(cat)

end

function ChaseEnter(agent)
    agent.r = 255
    agent.g = 0
    agent.b = 0
    
    MAX_ACCELERATION = 0.8	
end

function ChaseUpdate(agent)
    
    local x, y = Seek(agent, player.x, player.y)
    x, y = Normalize(x, y)
    agent.acceleration.x, agent.acceleration.y = Scale(x, y, MAX_ACCELERATION)
       
    TurnTo(agent, agent.velocity)
    UpdateEntity(agent)
    
    --transitions
    if GetDistanceToPlayer(agent) > CHASE_END_DISTANCE then 
        EnterState(agent, wanderState)
    end
end

function ChaseExit(agent)
    --do nothing
end

function FleeEnter(cat)

end

function FleeUpdate(cat)

	local x,y = Flee(cat, agent.x, agent.y)
	x, y = Normalize(x, y)
	cat.acceleration.x, cat.acceleration.y = Scale(x, y, MAX_ACCELERATION)
	
	TurnTo(cat, cat.velocity)
	UpdateEntity(cat)
	
	if GetDistanceToAgent(cat) > CHASE_END_DISTANCE then
		EnterState(cat, wanderState)
	end
end

function FleeExit(cat)

end

function PlayerUpdate(player)

	mouseX, mouseY = GetMousePosition()
	local x = 0
	local y = 0
	x,y = VectorTo(player.x, player.y, mouseX, mouseY)
	player.angle = math.deg(math.atan(y,x))

	if IsKeyDown(SDL_SCANCODE_A) then
        player.x = player.x - player.speed
    end
    
    if IsKeyDown(SDL_SCANCODE_D) then
        player.x = player.x + player.speed
    end
	
	if IsKeyDown(SDL_SCANCODE_W) then
        player.y = player.y - player.speed
    end
    
    if IsKeyDown(SDL_SCANCODE_S) then
        player.y = player.y + player.speed
    end
end


--------------------------------------------
-- state objects
--------------------------------------------

wanderState = {}
wanderState.name = "Wander"
wanderState.Enter = WanderEnter
wanderState.Update = WanderUpdate
wanderState.Exit = WanderExit

catWanderState = {}
catWanderState.name = "Cat Wander"
catWanderState.Enter = CatWanderEnter
catWanderState.Update = CatWanderEnter
catWanderState.Exit = CatWanderExit

chaseState = {}
chaseState.name = "Chase"
chaseState.Enter = ChaseEnter
chaseState.Update = ChaseUpdate
chaseState.Exit = ChaseExit

fleeState = {}
fleeState.name = "Flee"
fleeState.Enter = FleeEnter
fleeState.Update = FleeUpdate
fleeState.Exit = FleeExit

--------------------------------------------
-- mingine hooks
--------------------------------------------

function Start()
    CreateWindow(SCREEN_WIDTH, SCREEN_HEIGHT)
    SetWindowTitle("Agent State Machine Example.")
    
    font = LoadFont("fonts/8_bit_pusab.ttf", 16)
    
    local image = LoadImage("images/doge.png")
    agent = CreateEntity(image, SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2, 75, 75)
    agent.maxSpeed = 10
    agent.wanderAngle = 0
	
	local catImage = LoadImage("images/cat.png")
	cat = CreateEntity(catImage, SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2, 75,75)
	cat.maxSpeed = 10
	cat.wanderAngle = 0
	
	CreateStateMachine(agent, wanderState)
	CreateStateMachine(cat, fleeState)
	
	player = {}
	player.image = LoadImage("images/bone.png")
	player.x = SCREEN_WIDTH/2-37
	player.y = SCREEN_HEIGHT/2-37
	player.angle = 0
	player.speed = 10
	
	background = {}
	background.image = LoadImage("images/spaceImage.png")
	background.x = 0
	background.y = 0
    
end

function Update()
   UpdateStateMachine(agent)
   UpdateStateMachine(cat)
   PlayerUpdate(player)
   
   
end

function Draw()
    ClearScreen(68, 136, 204)
	DrawImage(background.image, background.x, background.y)
            
    SetDrawColor(255, 0, 255, 255)
              
    DrawEntity(agent)
	DrawEntity(cat)
    --line over agent represents direction of acceleration
    local accDirX, accDirY = Mad(agent, agent.acceleration, 32)
    --DrawLine(agent.x, agent.y, accDirX, accDirY) 

    DrawText("Dog's State: " .. agent.stateMachine.currentState.name, 8, 9, font, 255, 255, 255)
	DrawText("Cat's State: " .. cat.stateMachine.currentState.name, 8, 40, font, 255, 255, 255)
	
	--DrawEntity(player)
	DrawImage(player.image, player.x, player.y, player.angle)
	
end



