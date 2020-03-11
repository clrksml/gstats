print( "Loaded gStats by Clark" )

require("tmysql")

local PLAYER = _R.Player
tmysql.initialize( "localhost", "root", "", "gstats", 3306)

tmysql.query( "CREATE TABLE IF NOT EXISTS players ( steamid text NOT NULL, nick text NOT NULL, kills int(11) NOT NULL, deaths int(11) NOT NULL, headshots int(11) NOT NULL )", SQLHandle )

function SQLHandle( result, _, error )
	if error and error != 0 then
		print( "SQL ERROR: " .. error )
	end
end

function PLAYER:SetData(  )
	tmysql.query( "UPDATE players SET nick = '" .. tmysql.escape( self:Nick() ) .. "', kills = '" .. self:Frags() .. "', deaths = '" .. self:Deaths() .. "', headshots = '" .. self.HeadShots .. "' WHERE steamid= '" .. self:SteamID() .. "'", SQLHandle )
end

function PLAYER:GetData( )
	self.HeadShots = 0
	tmysql.query( "SELECT kills, deaths, headshots FROM players WHERE steamid '" .. self:SteamID() .. "'", function( Args )
		if !Args and !Args[1] then
			tmysql.query( "INSERT INTO players VALUES( '" .. tmysql.escape( self:SteamID() ) .. "', '" .. tmysql.escape( self:Nick() ) .. "', '" .. 0 .. "', '" .. 0 .. "', '" .. 0 .. "' )" )
			self:ChatPrint( "[gStats] New account created." )
		else
			self:SetFrags( tonumber(Args[1][1]))
			self:SetDeaths( tonumber(Args[1][2]))
			self.HeadShots = tonumber(Args[1][3])
			self:ChatPrint( "[gStats] Kills: " .. self:Frags() .. " Deaths: " .. self:Deaths() .. " HeadShots: " .. self.HeadShots )

		end
	end)
end

concommand.Add("g_rank", function( p, c, a )
	p:ChatPrint( "[gStats] Kills: " .. p:Frags() .. " Deaths: " .. p:Deaths() .. " HeadShots: " .. p.HeadShots )
end)

concommand.Add("g_ranks", function( p, c, a )
	for k, v in pairs(player.GetAll()) do
		p:ChatPrint( "[gStats] Name: " .. v:Nick() .. " Kills: " .. v:Frags() .. " Deaths: " .. v:Deaths() .. " HeadShots: " .. v.HeadShots )
	end
end)

hook.Add( "Initialize", "Tags", function( )
	game.ConsoleCommand("sv_tags gStats\n") // If you love me you'll tag your server.
end)

hook.Add( "PlayerInitialSpawn", "GetInfo", function( p )
	if !p:IsBot() then
		p:GetData( )
		p:ChatPrint( "[gStats] Welcome " .. p:Nick() .. ", this server is running gStats by Clark " )
	end
end)

hook.Add( "DoPlayerDeath", "Death", function( v, k, d)
	if killer == victim or !killer:IsValid() or !victim:IsValid() then return end
	if k.GotHeadShot then
		k.HeadShots = 1 + k.HeadShots
		k.GotHeadShot = false
	else
		k.HeadShots = k.HeadShots + 0
		k.GotHeadShot = false
	end
	k:SetData()
	k:ChatPrint( "[gStats] Your stats have been updated" )
end)

hook.Add( "ScalePlayerDamage", "Death", function( p, hit, dmg )
	if p:IsValid() and dmg:GetInflictor():IsValid() and p != dmg:GetInflictor() then
		if hit == HITGROUP_HEAD then
			dmg:GetInflictor().GotHeadShot = true
		else
			dmg:GetInflictor().GotHeadShot = false
		end
	 end
end)