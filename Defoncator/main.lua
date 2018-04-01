-- Cette ligne permet d'afficher des traces dans la console pendant l'éxécution
io.stdout:setvbuf('no')

-- Empèche Love de filtrer les contours des images quand elles sont redimentionnées
-- Indispensable pour du pixel art
love.graphics.setDefaultFilter("nearest")

-- Cette ligne permet de déboguer pas à pas dans ZeroBraneStudio
if arg[#arg] == "-debug" then require("mobdebug").start() end

math.randomseed(love.timer.getTime())

player={}

-- Listes d'elements
liste_Sprites = {}
liste_Tirs = {}
liste_Aliens = {}

-- charge les sons du jeu
sonShoot = love.audio.newSource("sons/shoot.wav", "static")
sonExplode = love.audio.newSource("sons/explode_touch.wav", "static")

-- niveau 16x12
niveau1 = {}
table.insert(niveau1, {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0})
table.insert(niveau1, {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0})
table.insert(niveau1, {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0})
table.insert(niveau1, {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0})
table.insert(niveau1, {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0})
table.insert(niveau1, {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0})
table.insert(niveau1, {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0})
table.insert(niveau1, {0,0,0,0,0,0,0,0,0,0,0,0,0,0,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0})
table.insert(niveau1, {0,0,0,0,0,0,0,0,0,0,0,0,0,0,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0})
table.insert(niveau1, {0,0,0,0,0,0,0,1,0,0,0,0,0,0,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0})
table.insert(niveau1, {0,0,0,0,0,0,1,1,1,0,0,0,0,0,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0})
table.insert(niveau1, {1,1,1,1,1,1,1,1,1,1,1,1,1,2,2,2,2,3,3,3,3,2,2,2,2,1,1,3,1,1,3,3})

-- Chargement des Images
--les tuiles
imgTuiles = {}
for n=1,3 do
  imgTuiles[n] = love.graphics.newImage("images/tuile_"..n..".png")
end
--les explosions
imgExplosion = {}
for n=1,5 do
  imgExplosion[n] = love.graphics.newImage("images/explode_"..n..".png")
end
-- le menu
imgMenu = love.graphics.newImage("images/menu.jpg")
-- le gameover
imgGameOver = love.graphics.newImage("images/gameover.jpg")
-- la victoire
imgVictoire = love.graphics.newImage("images/victory.jpg")

--Camera
camera = {}
camera.x = 0
camera.vitesse = -2

--ecran courant
ecran_courant = "menu"

-- timer de victoire
timerVictoire = 0
victoire = false

-- timer de gameover
timerGameOver = 0

-- fonction de calcul de collision
function collide(a1, a2)
  if (a1==a2) then return false end
  local dx = a1.x - a2.x
  local dy = a1.y - a2.y
  if (math.abs(dx) < a1.image:getWidth()+a2.image:getWidth()) then
    if (math.abs(dy) < a1.image:getHeight()+a2.image:getHeight()) then
      return true
    end
  end
  return false
end

-- calcul d'angle entre 2 pts
function math.angle(x1,y1, x2,y2) 
  return math.atan2(y2-y1, x2-x1)
end

function CreeTir(pType, pNomImage, pX, pY, pVitesseX, pVitesseY)
  local tir = CreeSprite(pNomImage, pX, pY)
  tir.type = pType
  tir.vX = pVitesseX
  tir.vY = pVitesseY
  table.insert(liste_Tirs, tir)
  sonShoot:stop()
  sonShoot:play()
end

function CreeAlien(pType, pX, pY)
  
  local nomImage=""
  if pType == 1 then
    nomImage = "enemy1"
  elseif pType == 2 then
    nomImage = "enemy2"
  elseif pType == 3 then
    nomImage = "enemy3"
    elseif pType == 4 then
    nomImage = "tourelle"
  end
  
  local alien = CreeSprite(nomImage,pX,pY)
  
  alien.type = pType
  alien.endormi = true
  alien.chronoTir = 0
  
  local directionAleatoire = math.random(-1,1)
  
  
  if pType == 1 then
    alien.vX = -3
    alien.vY = 0
    alien.energie = 1
  elseif pType == 2 then
    alien.vX = -3
    alien.vY = directionAleatoire
    alien.energie = 2
  elseif pType == 3 then -- boss
    alien.vX = camera.vitesse*2
    alien.vY = 0
    alien.energie = 20
    alien.angle = 0
  elseif pType == 4 then
    alien.vX = camera.vitesse
    alien.vY = 0
    alien.energie = 2
  end
  
  table.insert(liste_Aliens, alien)
  
end

function CreeExplosion(pX, pY)
  local newExplode = CreeSprite("explode_1", pX, pY)
  newExplode.listeFrames = imgExplosion
  newExplode.maxFrame = 5
end

function CreeSprite(pNomImage, pX, pY)

  sprite = {}
  sprite.x = pX
  sprite.y = pY
  sprite.toDelete = false
  sprite.image = love.graphics.newImage("images/"..pNomImage..".png")
  sprite.l = sprite.image:getWidth()
  sprite.h = sprite.image:getHeight()
  
  sprite.frame = 1
  sprite.listeFrames = {}
  sprite.maxFrame = 1
  
  table.insert(liste_Sprites, sprite)

  return sprite

end

function love.load()
  
  love.window.setMode(1024, 768)
  love.window.setTitle("defoncator")
  -- charge les dimensions de la fenetre
  largeur = love.graphics.getWidth()
  hauteur = love.graphics.getHeight()
  
  DemarreJeu()
  
end

function DemarreJeu()
  timerGameOver = 0
  liste_Sprites = {}
  liste_Tirs = {}
  liste_Aliens = {}
  --raz player
  player = CreeSprite("heros", 40, hauteur/2)
  player.vitesse = 4
  player.shield = 4
  --raz alien
  for i= 1, math.random(10,15) do
    local typeAlien = math.random(1,3)
    if typeAlien == 3 then
      CreeAlien(typeAlien+1,(64*(math.random(16,32))),hauteur-64)
    else
      CreeAlien(typeAlien,(64*(math.random(16,32))),math.random(64,700))
    end
  end
  CreeAlien(3,(64*32),hauteur/2)
  --raz camera
  camera.x = 0
  -- victoire
  victoire = false
  
end

function updateJeu()
  --avance camera
    camera.x = camera.x + camera.vitesse

    
    local n
    
    -- traitement des tirs
    for n=#liste_Tirs,1,-1 do
      local tir = liste_Tirs[n]
      tir.x = tir.x + tir.vX
      tir.y = tir.y + tir.vY
      
      --verifie si on touche le player
      if tir.type == "alien" then
        if collide(player,tir) then
          tir.toDelete = true
          if player.shield > 0 then
            player.shield = player.shield - 1
          elseif player.shield == 0 then
            ecran_courant = "gameOver"
          end
        end
      end
      
      --verifie si on touche un alien
      if tir.type == "player" then
        local nAlien
        for nAlien=#liste_Aliens, 1, -1 do
          local alien = liste_Aliens[nAlien]
          if alien.endormi == false then
            if collide(tir,alien) == true then
              CreeExplosion(tir.x, tir.y)
              tir.toDelete = true
              if alien.energie > 0 then
                alien.energie = alien.energie - 1
              elseif alien.energie == 0 then
                for nExplosion=1,5 do
                  CreeExplosion(alien.x + math.random(-10,10), alien.y + math.random(-10,10))
                end
                if alien.type ==  3 then
                  victoire = true
                  timerVictoire = 180
                  for nExplosion=1,20 do
                    CreeExplosion(alien.x + math.random(-100,100), alien.y + math.random(-100,100))
                  end
                end
                
                sonExplode:stop()
                sonExplode:play()
                alien.toDelete = true
                table.remove(liste_Aliens, nAlien)
              end
            end
          end
        end
      end
      
      --verifier si tir sorti de l'ecran
      if tir.y < 0 or tir.y > hauteur then
        tir.toDelete = true
      end
      if tir.x < 0 or tir.x > largeur then
        tir.toDelete = true
      end
      
      if tir.toDelete == true then
        table.remove(liste_Tirs, n)
      end
      
    end
    
    -- traitement des aliens
    for n=#liste_Aliens,1,-1 do
      local alien = liste_Aliens[n]
      
      if alien.x < largeur then
        alien.endormi = false
      end
      
      if alien.endormi == false then
        
        local vX, vY
        local angle
        angle = math.angle(alien.x,alien.y, player.x, player.y)
        vX = math.cos(angle)
        vY = math.sin(angle)
        
        if alien.type == 1 then
          alien.chronoTir = alien.chronoTir +1
          if alien.chronoTir >= 80 then
            alien.chronoTir = 0
            CreeTir("alien","laser2", alien.x-(64/2), alien.y, -10, 0)
          end
        elseif alien.type == 2 then
          alien.chronoTir = alien.chronoTir +1
          if alien.chronoTir >= 70 then
            alien.chronoTir = 0
            CreeTir("alien","laser2", alien.x-(64/2), alien.y, -10, 0)
          end
        elseif alien.type == 3 then
          if alien.x < (largeur-(largeur/3)) then
            alien.x = (largeur-(largeur/3))
                  alien.chronoTir = alien.chronoTir +1
                  if alien.chronoTir >= 5 then
                    alien.chronoTir = 0
                    alien.angle = alien.angle +0.2
                    vX = math.cos(alien.angle)
                    vY = math.sin(alien.angle)
                    CreeTir("alien","laser2", alien.x-(64/2), alien.y, 10*vX, 10*vY)
                  end
          end
        else --alien type 4 "tourelle"
          alien.chronoTir = alien.chronoTir +1
          if alien.chronoTir >= 50 then
            alien.chronoTir = 0
            CreeTir("alien","laser2", alien.x-(64/2), alien.y, 10*vX, 10*vY)
          end
        end
        alien.x = alien.x + alien.vX
        alien.y = alien.y + alien.vY
      else
        alien.x = alien.x + camera.vitesse
      end
      
      --verifier si alien sorti de l'ecran
      if alien.y < 0 or alien.y > hauteur then
        table.remove(liste_Aliens, n)
        alien.toDelete = true
      end
      --if alien.x < 0 or alien.x > largeur then
      if alien.x < 0 then
        table.remove(liste_Aliens, n)
        alien.toDelete = true
      end
      
    end
    
    -- traitement et verifier si sprite a detruire
    for n=#liste_Sprites,1,-1 do
      local sprite = liste_Sprites[n]
      --Le sprite est t'il annimé ?
      if sprite.maxFrame > 1 then
        sprite.frame = sprite.frame + 0.2
        if math.floor(sprite.frame) > sprite.maxFrame then
          sprite.toDelete = true
        else
          sprite.image = sprite.listeFrames[math.floor(sprite.frame)]
        end
      end
      
      if sprite.toDelete == true or (sprite.vX == 0 and sprite.vY == 0) then
        table.remove(liste_Sprites, n)
      end
    end
    
    if love.keyboard.isDown("right") and player.x < largeur then
      player.x = player.x + player.vitesse
    end
    if love.keyboard.isDown("left") and player.x > 0 then
      player.x = player.x - player.vitesse
    end
    if love.keyboard.isDown("up") and player.y > 0 then
      player.y = player.y - player.vitesse
    end
    if love.keyboard.isDown("down") and player.y < hauteur then
      player.y = player.y + player.vitesse
    end
    
    if victoire == true then
      timerVictoire = timerVictoire -1
      if timerVictoire == 0 then
        ecran_courant = "victoire"
      end
    end
end

function updateMenu()
      DemarreJeu()
end

function updateGameOver()
  if timerGameOver < 180 then
    timerGameOver = timerGameOver + 1
  else
    DemarreJeu()
  end
end

function updateVictoire()
DemarreJeu()
end

function love.update(dt)
  if ecran_courant == "jeu" then
    updateJeu()
  elseif ecran_courant == "menu" then
    updateMenu()
  elseif ecran_courant == "gameOver" then
    updateGameOver()
  elseif ecran_courant == "victoire" then
    updateVictoire()
  end
end

function drawJeu()
  -- dessin du niveau
  local nbLignes = #niveau1
  local ligne,colonne
  local x = 0 + camera.x
  local y = 0 
  
  for ligne=1, nbLignes do
    for colonne=1, 32 do
      local tuile = niveau1[ligne][colonne]
      if tuile > 0 then
        love.graphics.draw(imgTuiles[tuile],x,y,0,2,2)
      end
      x = x + 64
    end
    x= camera.x
    y = y + 64
  end
    
  local n
  
  for n=1, #liste_Sprites do
    local s = liste_Sprites[n]
    love.graphics.draw(s.image, s.x, s.y, 0, 2, 2, s.l/2, s.h/2)
  end
  
  love.graphics.print("nombre de tirs : "..#liste_Tirs,0 ,0)
  love.graphics.print("nombre de sprites : "..#liste_Sprites,0 ,13)
end

function drawMenu()
  love.graphics.draw(imgMenu,0,0)
end

function drawGameOver()
  love.graphics.draw(imgGameOver,0,0)
end

function drawVictoire()
  love.graphics.draw(imgVictoire,0,0)
end

function love.draw()
  if ecran_courant == "jeu" then
    drawJeu()
  elseif ecran_courant == "menu" then
    drawMenu()
  elseif ecran_courant == "gameOver" then
    drawGameOver()
  elseif ecran_courant == "victoire" then
    drawVictoire()
  end
end

function love.keypressed(key)
  print(key)
  if ecran_courant == "jeu" then
    if key == "space" then
      CreeTir("player","laser1", player.x + player.l, player.y, 10, 0)
    end
    if key == "escape" then
      ecran_courant = "menu"
      
    end
  elseif ecran_courant == "menu" then
    if key =="space" then
      ecran_courant = "jeu"
    end
  elseif ecran_courant == "gameOver" then
    if key =="return" then
      ecran_courant = "menu"
    end
  elseif ecran_courant == "victoire" then
    if key =="return" then
      ecran_courant = "menu"
    end
  end
end