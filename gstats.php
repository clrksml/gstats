<?php
 $dbhost = 'localhost';
$dbuser = 'root';
$dbpass = '';
$dbname = 'gstats';
 
$conn = mysql_connect ($dbhost, $dbuser, $dbpass) or die ('Cannot connect to the database because: ' . mysql_error());
mysql_select_db ($dbname) or die('Could not select the database ' . $dbname . '!');
 
$query  = "SELECT steamid, nick, kills, deaths, headshots FROM players WHERE kills>1 order by kills DESC";
$results = mysql_query($query);

echo "<center><br><br> <SPAN STYLE='font-size: 16pt; font-family: arial'><b>Player Stats</span>
	<table border='0' cellspacing='1' cellpadding='1' style='color: #cccccc;background: #454545;'>
		<tr>
			<td align='center'><b>Name</b></td>
			<td align='center'><b>Kills</b></td>
			<td align='center'><b>Deaths</b></td>       
			<td align='center'><b>Headhots</b></td>
			<td align='center'><b>Steam ID</b></td>
		</tr>";
 
while($row = mysql_fetch_array($results, MYSQL_ASSOC))
{

 $steamId = $row['steamid'];

    $gameType = 0;
    $authServer = 0;
    $steamId = str_replace('STEAM_', '' ,$steamId);
    $parts = explode(':', $steamId);
    $gameType = $parts[0];
    $authServer = $parts[1];
    $clientId = $parts[2];
    $res = bcadd((bcadd('76561197960265728', $authServer)), (bcmul($clientId, '2')));
    $cid = str_replace('.0000000000', '', $res);
    $url = 'http://www.steamcommunity.com/profiles/';
	
echo "<tr align='center' >
		<td>{$row['nick']}</td>
		<td>{$row['kills']}</td>
		<td>{$row['deaths']}</td>
		<td>{$row['headshots']}</td>
		<td><a href={$url}{$cid}>{$row['steamid']}</a></td>
	</tr>";
}
echo "</table></center>";
?>
