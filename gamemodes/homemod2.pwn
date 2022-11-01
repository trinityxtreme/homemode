// Immortal Home Server | Version 2.0.0
// Start date: 2015-03-12 11:45 | by: MR.ImmortaL

/* TODO List:
	- /iwantyou | get people into team
	- /bugreport | standard bug report
	
	- admin system | level-based, /jetpack, /jail, /watch, /goto, /get
	- home system | safer (for money), home-style, lock
	- car system | go gallery and buy a car and save changes.
	- car management
	- hormonal level system (my very special system :^) (with updates like; it's a hidden system.)
	- business system
	- job system
	*make: /v & /tp command
	*make: /commands command
	*make: /repair, /cc commands
	*make: some survival things (hidden mini jobs)
*/

/* ADMIN LEVELS:

	0 - NOT A ADMIN
	1 - In-test admin: /watch, /jail, /reports, /slap
	2 - Low level admin: /kick, /goto, /warn, /clearchat
	3 - Admin: /jetpack, /announcement, /get, /shutup, /freeze
	4 - High level admin: /ban, /banip, /giveweapon, /killplayer
	5 - Superuser: /makeadmin, /restart, /respawncars, /god
*/

// (( Headers & preproccessor ))==============================================//
// Headers
#include <a_samp>
#include <YSI\y_ini>
#include <sscanf2>

// Preproccessor
// - Server settings
#define SERVER_HOSTNAME    		 "Immortal Home Server ||" // The hostname
#define SERVER_MAPNAME      	"San Andreas"
#define SERVER_WEBURL       	"www.sa-mp.com"
#define SERVER_FORUMURL			"No forum... yet."
#define SERVER_TEAM         	"one" // How many people in dev. team

#if defined MAX_PLAYERS
	#undef MAX_PLAYERS
#endif
#define MAX_PLAYERS         	100

// - Gamemode settings
#define GAMEMODE_NAME       	"homemod" 	// Modename. Pure and simple, isn't it?
#define GAMEMODE_VERSION    	"2.0.0" 	// Gamemode version.
#define SECURE_PINGLIMIT    	(400) 		// Ping limit.
#define SECURE_LOGINFAIL		(3)
#define DIALOGID_LIMIT			(20) 		// Dialog id limit. | 0-to-LIMIT per dialog.
#define FILE_ACCOUNTS       	"homemod/accounts/"  // Account file location

// - Message handler
#define SendErrorMessage(%0,%1) SendClientMessage(%0, 0xF63845AA, "» ERROR: {cccccc}" %1)
#define SendInfoMessage(%0,%1) SendClientMessage(%0, 0x00A2F6AA, "» INFO: {cccccc}" %1)
#define SendUsageMessage(%0,%1) SendClientMessage(%0, 0x8C50FFAA, "» USAGE: {cccccc}" %1)
#define SendMessageToAll(%0) SendClientMessageToAll(0x00A2F6AA, %0)

// - Account system settings
#define ADMINITY_KICK_LEVEL		(2)
#define ADMINITY_ANNOUNCE_LEVEL (3)
#define ADMINITY_BAN_LEVEL		(4)
#define ADMINITY_BANIP_LEVEL	(4)
#define ADMINITY_MAKE_LEVEL		(5)

// - DCMD
#define dcmd(%1,%2,%3) if (!strcmp((%3)[1], #%1, true, (%2)) && ((((%3)[(%2) + 1] == '\0') && (dcmd_%1(playerid, ""))) || (((%3)[(%2) + 1] == ' ') && (dcmd_%1(playerid, (%3)[(%2) + 2]))))) return 1

// (( Variable declaration ))=================================================//
// Player colors
new gPlayerColors[500] = {
	0x640D1BFF, 0xF5F5F5FF, 0x2A77A1FF, 0x840410FF, 0x263739FF, 0x86446EFF, 0xD78E10FF, 0x4C75B7FF, 0xBDBEC6FF, 0x5E7072FF,
	0x46597AFF, 0x656A79FF, 0x5D7E8DFF, 0x58595AFF, 0xD6DAD6FF, 0x9CA1A3FF, 0x335F3FFF, 0x730E1AFF, 0x7B0A2AFF, 0x9F9D94FF,
	0x3B4E78FF, 0x732E3EFF, 0x691E3BFF, 0x96918CFF, 0x515459FF, 0x3F3E45FF, 0xA5A9A7FF, 0x635C5AFF, 0x3D4A68FF, 0x979592FF,
	0x421F21FF, 0x5F272BFF, 0x8494ABFF, 0x767B7CFF, 0x646464FF, 0x5A5752FF, 0x252527FF, 0x2D3A35FF, 0x93A396FF, 0x6D7A88FF,
	0x221918FF, 0x6F675FFF, 0x7C1C2AFF, 0x5F0A15FF, 0x193826FF, 0x5D1B20FF, 0x9D9872FF, 0x7A7560FF, 0x989586FF, 0xADB0B0FF,
	0x848988FF, 0x304F45FF, 0x4D6268FF, 0x162248FF, 0x272F4BFF, 0x7D6256FF, 0x9EA4ABFF, 0x9C8D71FF, 0x6D1822FF, 0x4E6881FF,
	0x9C9C98FF, 0x917347FF, 0x661C26FF, 0x949D9FFF, 0xA4A7A5FF, 0x8E8C46FF, 0x341A1EFF, 0x6A7A8CFF, 0xAAAD8EFF, 0xAB988FFF,
	0x851F2EFF, 0x6F8297FF, 0x585853FF, 0x9AA790FF, 0x601A23FF, 0x20202CFF, 0xA4A096FF, 0xAA9D84FF, 0x78222BFF, 0x0E316DFF,
	0x722A3FFF, 0x7B715EFF, 0x741D28FF, 0x1E2E32FF, 0x4D322FFF, 0x7C1B44FF, 0x2E5B20FF, 0x395A83FF, 0x6D2837FF, 0xA7A28FFF,
	0xAFB1B1FF, 0x364155FF, 0x6D6C6EFF, 0x0F6A89FF, 0x204B6BFF, 0x2B3E57FF, 0x9B9F9DFF, 0x6C8495FF, 0x4D8495FF, 0xAE9B7FFF,
	0x406C8FFF, 0x1F253BFF, 0xAB9276FF, 0x134573FF, 0x96816CFF, 0x64686AFF, 0x105082FF, 0xA19983FF, 0x385694FF, 0x525661FF,
	0x7F6956FF, 0x8C929AFF, 0x596E87FF, 0x473532FF, 0x44624FFF, 0x730A27FF, 0x223457FF, 0xEC6AAEFF, 0xA3ADC6FF, 0x695853FF,
	0x9B8B80FF, 0x620B1CFF, 0x5B5D5EFF, 0x624428FF, 0x731827FF, 0x1B376DFF, 0xEC6AAEFF, 0x640D1BFF, 0xD8C762FF, 0xD8C762FF,
	0x177517FF, 0x210606FF, 0x125478FF, 0x452A0DFF, 0x571E1EFF, 0x010701FF, 0x25225AFF, 0x2C89AAFF, 0x8A4DBDFF, 0x35963AFF,
	0xB7B7B7FF, 0x464C8DFF, 0x84888CFF, 0x817867FF, 0x817A26FF, 0x6A506FFF, 0x583E6FFF, 0x8CB972FF, 0x824F78FF, 0x6D276AFF,
	0x1E1D13FF, 0x1E1306FF, 0x1F2518FF, 0x2C4531FF, 0x1E4C99FF, 0x2E5F43FF, 0x1E9948FF, 0x1E9999FF, 0x999976FF, 0x7C8499FF,
	0x992E1EFF, 0x2C1E08FF, 0x142407FF, 0x993E4DFF, 0x1E4C99FF, 0x198181FF, 0x1A292AFF, 0x16616FFF, 0x1B6687FF, 0x6C3F99FF,
	0x481A0EFF, 0x7A7399FF, 0x746D99FF, 0x53387EFF, 0x222407FF, 0x3E190CFF, 0x46210EFF, 0x991E1EFF, 0x8D4C8DFF, 0x805B80FF,
	0x7B3E7EFF, 0x3C1737FF, 0x733517FF, 0x781818FF, 0x83341AFF, 0x8E2F1CFF, 0x7E3E53FF, 0x7C6D7CFF, 0x020C02FF, 0x072407FF,
	0x163012FF, 0x16301BFF, 0x642B4FFF, 0x368452FF, 0x999590FF, 0x818D96FF, 0x99991EFF, 0x7F994CFF, 0x839292FF, 0x788222FF,
	0x2B3C99FF, 0x3A3A0BFF, 0x8A794EFF, 0x0E1F49FF, 0x15371CFF, 0x15273AFF, 0x375775FF, 0x060820FF, 0x071326FF, 0x20394BFF,
	0x2C5089FF, 0x15426CFF, 0x103250FF, 0x241663FF, 0x692015FF, 0x8C8D94FF, 0x516013FF, 0x090F02FF, 0x8C573AFF, 0x52888EFF,
	0x995C52FF, 0x99581EFF, 0x993A63FF, 0x998F4EFF, 0x99311EFF, 0x0D1842FF, 0x521E1EFF, 0x42420DFF, 0x4C991EFF, 0x082A1DFF,
	0x96821DFF, 0x197F19FF, 0x3B141FFF, 0x745217FF, 0x893F8DFF, 0x7E1A6CFF, 0x0B370BFF, 0x27450DFF, 0x071F24FF, 0x784573FF,
	0x8A653AFF, 0x732617FF, 0x319490FF, 0x56941DFF, 0x59163DFF, 0x1B8A2FFF, 0x38160BFF, 0x041804FF, 0x355D8EFF, 0x2E3F5BFF,
	0x561A28FF, 0x4E0E27FF, 0x706C67FF, 0x3B3E42FF, 0x2E2D33FF, 0x7B7E7DFF, 0x4A4442FF, 0x28344EFF, 0xE59338FF, 0xEEDC2DFF,
	0xFF8C13FF, 0xC715FFFF, 0x20B2AAFF, 0xDC143CFF, 0x6495EDFF, 0xf0e68cFF, 0x778899FF, 0xFF1493FF, 0xF4A460FF, 0x824F78FF,
	0xEE82EEFF, 0xFFD720FF, 0x8b4513FF, 0x4949A0FF, 0x148b8bFF, 0x14ff7fFF, 0x556b2fFF, 0x0FD9FAFF, 0x10DC29FF, 0x86446EFF,
	0x534081FF, 0x0495CDFF, 0xEF6CE8FF, 0xBD34DAFF, 0x247C1BFF, 0x0C8E5DFF, 0x635B03FF, 0xCB7ED3FF, 0x65ADEBFF, 0x20202CFF,
	0x5C1ACCFF, 0xF2F853FF, 0x11F891FF, 0x7B39AAFF, 0x53EB10FF, 0x54137DFF, 0x275222FF, 0xF09F5BFF, 0x3D0A4FFF, 0xC471BDFF,
	0x22F767FF, 0xD63034FF, 0x9A6980FF, 0xDFB935FF, 0x3793FAFF, 0x90239DFF, 0xE9AB2FFF, 0xAF2FF3FF, 0x057F94FF, 0x991E1EFF,
	0xB98519FF, 0x388EEAFF, 0x028151FF, 0xA55043FF, 0x0DE018FF, 0x93AB1CFF, 0x95BAF0FF, 0x369976FF, 0x18F71FFF, 0x020C02FF,
	0x4B8987FF, 0x491B9EFF, 0x829DC7FF, 0xBCE635FF, 0xCEA6DFFF, 0x20D4ADFF, 0x2D74FDFF, 0x3C1C0DFF, 0x12D6D4FF, 0x38160BFF,
	0x48C000FF, 0x2A51E2FF, 0xE3AC12FF, 0xFC42A8FF, 0x2FC827FF, 0x1A30BFFF, 0xB740C2FF, 0x42ACF5FF, 0x2FD9DEFF, 0x247C1BFF,
	0xFAFB71FF, 0x05D1CDFF, 0xC471BDFF, 0x94436EFF, 0xC1F7ECFF, 0xCE79EEFF, 0xBD1EF2FF, 0x93B7E4FF, 0x3214AAFF, 0xAF2FF3FF,
	0x184D3BFF, 0xAE4B99FF, 0x7E49D7FF, 0x4C436EFF, 0xFA24CCFF, 0xCE76BEFF, 0xA04E0AFF, 0x9F945CFF, 0xDCDE3DFF, 0x6495EDFF,
	0x10C9C5FF, 0x70524DFF, 0x0BE472FF, 0x8A2CD7FF, 0x6152C2FF, 0xCF72A9FF, 0xE59338FF, 0xEEDC2DFF, 0xD8C762FF, 0xFAFB71FF,
	0xD8C762FF, 0xFF8C13FF, 0xC715FFFF, 0x20B2AAFF, 0xDC143CFF, 0x6495EDFF, 0xf0e68cFF, 0x778899FF, 0xFF1493FF, 0x0B370BFF,
	0xF4A460FF, 0xEE82EEFF, 0xFFD720FF, 0x8b4513FF, 0x4949A0FF, 0x148b8bFF, 0x14ff7fFF, 0x556b2fFF, 0x0FD9FAFF, 0xBCE635FF,
	0x10DC29FF, 0x534081FF, 0x0495CDFF, 0xEF6CE8FF, 0xBD34DAFF, 0x247C1BFF, 0x0C8E5DFF, 0x635B03FF, 0xCB7ED3FF, 0x90239DFF,
	0x65ADEBFF, 0x5C1ACCFF, 0xF2F853FF, 0x11F891FF, 0x7B39AAFF, 0x53EB10FF, 0x54137DFF, 0x275222FF, 0xF09F5BFF, 0xCF72A9FF,
	0x3D0A4FFF, 0x22F767FF, 0xD63034FF, 0x9A6980FF, 0xDFB935FF, 0x3793FAFF, 0x90239DFF, 0xE9AB2FFF, 0xAF2FF3FF, 0x6152C2FF,
	0x057F94FF, 0xB98519FF, 0x388EEAFF, 0x028151FF, 0xA55043FF, 0x0DE018FF, 0x93AB1CFF, 0x95BAF0FF, 0x369976FF, 0x8A2CD7FF,
	0x18F71FFF, 0x4B8987FF, 0x491B9EFF, 0x829DC7FF, 0xBCE635FF, 0xCEA6DFFF, 0x20D4ADFF, 0x2D74FDFF, 0x3C1C0DFF, 0x0BE472FF,
	0x12D6D4FF, 0x48C000FF, 0x2A51E2FF, 0xE3AC12FF, 0xFC42A8FF, 0x2FC827FF, 0x1A30BFFF, 0xB740C2FF, 0x42ACF5FF, 0x70524DFF,
	0x2FD9DEFF, 0xFAFB71FF, 0x05D1CDFF, 0xC471BDFF, 0x94436EFF, 0xC1F7ECFF, 0xCE79EEFF, 0xBD1EF2FF, 0x93B7E4FF, 0x10C9C5FF,
	0x3214AAFF, 0x184D3BFF, 0xAE4B99FF, 0x7E49D7FF, 0x4C436EFF, 0xFA24CCFF, 0xCE76BEFF, 0xA04E0AFF, 0x9F945CFF, 0xDCDE3DFF,
	0x1E1D13FF, 0x1E1306FF, 0x1F2518FF, 0x2C4531FF, 0x1E4C99FF, 0x2E5F43FF, 0x1E9948FF, 0x1E9999FF, 0x999976FF, 0x7C8499FF,
	0x992E1EFF, 0x2C1E08FF, 0x142407FF, 0x993E4DFF, 0x1E4C99FF, 0x198181FF, 0x1A292AFF, 0x16616FFF, 0x1B6687FF, 0x6C3F99FF,
	0x481A0EFF, 0x7A7399FF, 0x746D99FF, 0x53387EFF, 0x222407FF, 0x3E190CFF, 0x46210EFF, 0x991E1EFF, 0x8D4C8DFF, 0x805B80FF
};

// Spawn positions
new Float:gRandomSpawnPos[23][3] = {
	{1958.3783, 1343.1572, 15.3746}, {2199.6531, 1393.3678, 10.8203}, {2483.5977, 1222.0825, 10.8203},
	{2637.2712, 1129.2743, 11.1797}, {2000.0106, 1521.1111, 17.0625}, {2244.2566, 2523.7280, 10.8203},
	{2024.8190, 1917.9425, 12.3386}, {2261.9048, 2035.9547, 10.8203}, {2262.0986, 2398.6572, 10.8203},
	{2335.3228, 2786.4478, 10.8203}, {2150.0186, 2734.2297, 11.1763}, {2158.0811, 2797.5488, 10.8203},
	{1969.8301, 2722.8564, 10.8203}, {1652.0555, 2709.4072, 10.8265}, {1564.0052, 2756.9463, 10.8203},
	{1271.5452, 2554.0227, 10.8203}, {1441.5894, 2567.9099, 10.8203}, {1480.6473, 2213.5718, 11.0234},
	{1400.5906, 2225.6960, 11.0234}, {1598.8419, 2221.5676, 11.0625}, {1318.7759, 1251.3580, 10.8203},
	{1558.0731, 1007.8292, 10.8125}, {1705.2347, 1025.6808, 10.8203}
};

// Dialog declaration
enum
{
	DID_MSGBOX = 0,
	DID_HELP = DIALOGID_LIMIT,
	DID_GAMEMODE = DIALOGID_LIMIT * 2,
	DID_CHANGELOG = DIALOGID_LIMIT * 3,
	DID_IWANTYOU = DIALOGID_LIMIT * 4,
	DID_ACCOUNTS = DIALOGID_LIMIT * 5
}

// - Dialog pages
new gameModeDialog[][] = {
		"Adminity system\t{cccccc}[Version: 1.0.0]\t[{00FF33}ACTIVE{cccccc}]",
	    "Account system\t\t{cccccc}[Version: 1.0.0]\t[{00FF33}ACTIVE{cccccc}]",
		"Gamemode backbone\t{cccccc}[Version: 2.0.0]\t[{00FF33}ACTIVE{cccccc}]"
};

new changeLog[][][] = {
	{
		"[2015-03-27] Adminity updated, Account bugfix, some basic updates.",
		"[2015-03-26] Account system updated, Adminity system created.",
		"[2015-03-23] Account system, cars, random spawn and more!",
	    "[2015-03-22] Account system created, some bugfixes.",
	    "[2015-03-20] \"/kill\" command added.",
		"[2015-03-18] Ping limit & connect/disconnect/death texts added.",
		"[2015-03-16] Some basic commands added.",
		"[2015-03-12] Gamemode version 2.0.0 started."
	}
};

new commandList[][] = {
	"/help\tOpens help menu.",
	"/gamemode\tOpens active systems menu.",
	"/changelog\tOpens a log of gamemode changes.",
	"/iwantyou\tOpens a panel for server development team enterence.",
	"/commands\tOpens a list of little commands.",
	"/killme\tKill your character.",
	"/mypos\tGives your current location and facing angle.",
	"/clear\tClears screen."
};

// Account system
enum playerData
{
	p_Exist,
	p_LoggedIn,
	p_LoginTry,
	p_Password,
	p_Adminity,
	p_Banned,
	p_Kills,
	p_Deaths,
	p_Score,
	p_Money,
	p_IP[16],
	p_Jail,
	p_CreateDate[24],
	p_LastLogin[24]
}

new gPlayerData[MAX_PLAYERS][playerData];
new gPlayerRandomColor[MAX_PLAYERS];
new gPlayerFirstPassword[MAX_PLAYERS];

// Time system
enum timeData
{
	t_Hour,
	t_Minute,
	t_Timer,
	Text:t_Textdraw
}

new gTimeData[timeData];

// Textdraws
new Text:Textdraw_General, Text:Textdraw_Announce;
new PlayerText:Textdraw_Info;
new AnnounceTimer;

// (( Functions ))============================================================//
// General
getName(playerid)
{
	new buff[MAX_PLAYER_NAME];
	GetPlayerName(playerid, buff, sizeof(buff));
	return buff;
}

getDateTimeOnString()
{
	new buff[24];
	new year, month, day;
	new hour, minute, second;
	
	getdate(year, month, day);
	gettime(hour, minute, second);
	format(buff, sizeof(buff), "%i-%i-%i %i:%i:%i", year, month, day, hour, minute, second);
	
	return buff;
}

stock udb_hash(buf[]) 
{
	new length = strlen(buf);
    new s1 = 1, s2 = 0;
    
    for (new n = 0; n < length; n++)
    {
       s1 = (s1 + buf[n]) % 65521;
       s2 = (s2 + s1)     % 65521;
    }
	
    return (s2 << 16) + s1;
}

// Account system
forward userFunction_playerData(playerid, name[], value[]);
public userFunction_playerData(playerid, name[], value[])
{
	INI_Int("password", gPlayerData[playerid][p_Password]);
	INI_Int("adminity", gPlayerData[playerid][p_Adminity]);
	INI_Int("banned", gPlayerData[playerid][p_Banned]);
	INI_Int("kills", gPlayerData[playerid][p_Kills]);
	INI_Int("deaths", gPlayerData[playerid][p_Deaths]);
	INI_Int("score", gPlayerData[playerid][p_Score]);
	INI_Int("money", gPlayerData[playerid][p_Money]);
	INI_String("ip", gPlayerData[playerid][p_IP], 16);
	INI_Int("jail", gPlayerData[playerid][p_Jail]);
	INI_String("create_date", gPlayerData[playerid][p_CreateDate], 24);
	INI_String("last_login", gPlayerData[playerid][p_LastLogin], 24);
	return 1;
}

PlayerUpdateName(playerid, new_name[])
{
	new INI:userFile = INI_Open(GetPlayerFileFromName(new_name));
	INI_SetTag(userFile, "playerData");
	INI_WriteInt(userFile, "password", gPlayerData[playerid][p_Password]);
	INI_WriteInt(userFile, "adminity", gPlayerData[playerid][p_Adminity]);
	INI_WriteInt(userFile, "banned", gPlayerData[playerid][p_Banned]);
	INI_WriteInt(userFile, "kills", gPlayerData[playerid][p_Kills]);
	INI_WriteInt(userFile, "deaths", gPlayerData[playerid][p_Deaths]);
	INI_WriteInt(userFile, "score", gPlayerData[playerid][p_Score]);
	INI_WriteInt(userFile, "money", gPlayerData[playerid][p_Money]);
	INI_WriteString(userFile, "ip", gPlayerData[playerid][p_IP]);
	INI_WriteInt(userFile, "jail", gPlayerData[playerid][p_Jail]);
	INI_WriteString(userFile, "create_date", gPlayerData[playerid][p_CreateDate]);
	INI_WriteString(userFile, "last_login", gPlayerData[playerid][p_LastLogin]);
	INI_Close(userFile);
	fremove(getName(playerid));
	return 1;
}

PlayerNew(playerid, password)
{
	new playerIP[16];
	GetPlayerIp(playerid, playerIP, sizeof(playerIP));
	
	new lDay, lMonth, lYear;
	new lHour, lMinute, lSecond;
	getdate(lYear, lMonth, lDay);
	gettime(lHour, lMinute, lSecond);
	
	new buff[24];
	format(buff, sizeof(buff), "%i-%i-%i %i:%i:%i", lYear, lMonth, lDay, lHour, lMinute, lSecond);
	
	gPlayerData[playerid][p_Password] = password;
	gPlayerData[playerid][p_Adminity] = 0;
	gPlayerData[playerid][p_Banned] = false;
	gPlayerData[playerid][p_Kills] = 0;
	gPlayerData[playerid][p_Deaths] = 0;
	gPlayerData[playerid][p_Score] = GetPlayerScore(playerid);
	gPlayerData[playerid][p_Money] = GetPlayerMoney(playerid);
	gPlayerData[playerid][p_IP] = playerIP;
	gPlayerData[playerid][p_Jail] = 0;
	gPlayerData[playerid][p_CreateDate] = buff;
	gPlayerData[playerid][p_LastLogin] = buff;
	
	new INI:userFile = INI_Open(GetPlayerFile(playerid));
	INI_SetTag(userFile, "playerData");
	INI_WriteInt(userFile, "password", gPlayerData[playerid][p_Password]);
	INI_WriteInt(userFile, "adminity", gPlayerData[playerid][p_Adminity]);
	INI_WriteInt(userFile, "banned", gPlayerData[playerid][p_Banned]);
	INI_WriteInt(userFile, "kills", gPlayerData[playerid][p_Kills]);
	INI_WriteInt(userFile, "deaths", gPlayerData[playerid][p_Deaths]);
	INI_WriteInt(userFile, "score", gPlayerData[playerid][p_Score]);
	INI_WriteInt(userFile, "money", gPlayerData[playerid][p_Money]);
	INI_WriteString(userFile, "ip", gPlayerData[playerid][p_IP]);
	INI_WriteInt(userFile, "jail", gPlayerData[playerid][p_Jail]);
	INI_WriteString(userFile, "create_date", gPlayerData[playerid][p_CreateDate]);
	INI_WriteString(userFile, "last_login", gPlayerData[playerid][p_LastLogin]);
	INI_Close(userFile);
}

PlayerSave(playerid)
{
	new INI:userFile = INI_Open(GetPlayerFile(playerid));
	
	new lDay, lMonth, lYear;
	new lHour, lMinute, lSecond;
	getdate(lYear, lMonth, lDay);
	gettime(lHour, lMinute, lSecond);
	
	new buff[24];
	format(buff, sizeof(buff), "%i-%i-%i %i:%i:%i", lYear, lMonth, lDay, lHour, lMinute, lSecond);
	
	INI_SetTag(userFile, "playerData");
	INI_WriteInt(userFile, "password", gPlayerData[playerid][p_Password]);
	INI_WriteInt(userFile, "adminity", gPlayerData[playerid][p_Adminity]);
	INI_WriteInt(userFile, "banned", gPlayerData[playerid][p_Banned]);
	INI_WriteInt(userFile, "kills", gPlayerData[playerid][p_Kills]);
	INI_WriteInt(userFile, "deaths", gPlayerData[playerid][p_Deaths]);
	INI_WriteInt(userFile, "score", gPlayerData[playerid][p_Score]);
	INI_WriteInt(userFile, "money", gPlayerData[playerid][p_Money]);
	INI_WriteString(userFile, "ip", gPlayerData[playerid][p_IP]);
	INI_WriteInt(userFile, "jail", gPlayerData[playerid][p_Jail]);
	INI_WriteString(userFile, "create_date", gPlayerData[playerid][p_CreateDate]);
	INI_WriteString(userFile, "last_login", buff);
	INI_Close(userFile);
}

GetPlayerFile(playerid)
{
	new userFile[64 + MAX_PLAYER_NAME];
	format(userFile, sizeof(userFile), "%s/%s.ini", FILE_ACCOUNTS, getName(playerid));
	return userFile;
}

GetPlayerFileFromName(player_name[])
{
	new userFile[64 + MAX_PLAYER_NAME];
	format(userFile, sizeof(userFile), "%s/%s.ini", FILE_ACCOUNTS, player_name);
	return userFile;
}

KickPlayer(playerid)
{
	SetTimerEx("Kicking", 0050, 0, "i", playerid);
}

BanPlayer(playerid, reason[])
{
	SetTimerEx("Banning", 0050, 0, "i", playerid, reason);
}

forward Kicking(playerid);
public Kicking(playerid)
{
	Kick(playerid);
}

forward Banning(playerid, reason[]);
public Banning(playerid, reason[])
{
	BanEx(playerid, reason);
}

ShowAnnounce(time)
{
	TextDrawShowForAll(Textdraw_Announce);
	AnnounceTimer = SetTimer("HideAnnounce", time  * 1000, 0);
}

forward HideAnnounce();
public HideAnnounce()
{
	TextDrawHideForAll(Textdraw_Announce);
	KillTimer(AnnounceTimer);
}

// Time system
forward TimeUpdate();
public TimeUpdate()
{
	gTimeData[t_Minute]++;
	if(gTimeData[t_Minute] == 60 && gTimeData[t_Hour] < 24)
	{
		gTimeData[t_Hour]++;
		gTimeData[t_Minute] = 0;
		SetWorldTime(gTimeData[t_Hour]);
	}
	
	if(gTimeData[t_Hour] == 24 && gTimeData[t_Minute] == 0)
	{
		gTimeData[t_Hour] = 0;
		gTimeData[t_Minute] = 0;
		SetWorldTime(gTimeData[t_Hour]);
	}
	
	new buff[6];
	format(buff, sizeof(buff), "%02d:%02d", gTimeData[t_Hour], gTimeData[t_Minute]);
	TextDrawSetString(gTimeData[t_Textdraw], buff);
	
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		if(!IsPlayerConnected(i)) continue;
		SetPlayerTime(i, gTimeData[t_Hour], gTimeData[t_Minute]);
	}
	
	return 1;
}

// Player timer
new playerTimer[MAX_PLAYERS];

forward PlayerUpdateTimer(playerid);
public PlayerUpdateTimer(playerid)
{
	// Player textdraw
	new buff[48], pingColor[7];
	
	if(GetPlayerPing(playerid) < SECURE_PINGLIMIT / 4 * 1 && SECURE_PINGLIMIT / 4 * 0 > GetPlayerPing(playerid))
	{
		pingColor = "~g~~h~";
	}
	else if(GetPlayerPing(playerid) < SECURE_PINGLIMIT / 4 * 2 && SECURE_PINGLIMIT / 4 * 1 > GetPlayerPing(playerid))
	{
		pingColor = "~g~";
	}
	else if(GetPlayerPing(playerid) < SECURE_PINGLIMIT / 4 * 3 && SECURE_PINGLIMIT / 4 * 2 > GetPlayerPing(playerid))
	{
		pingColor = "~y~~h~";
	}
	else if(GetPlayerPing(playerid) < SECURE_PINGLIMIT / 4 * 4 && SECURE_PINGLIMIT / 4 * 3 > GetPlayerPing(playerid))
	{
		pingColor = "~y~";
	}
	else if(GetPlayerPing(playerid) < SECURE_PINGLIMIT && SECURE_PINGLIMIT / 4 * 4 > GetPlayerPing(playerid))
	{
		pingColor = "~r~~h~";
	}
	else if(GetPlayerPing(playerid) > SECURE_PINGLIMIT)
	{
		SendInfoMessage(playerid, "Your ping is too much for server, you're kicked.");
		pingColor = "~r~";
		KickPlayer(playerid);
	}
	
	format(buff, sizeof(buff), "Ping: %s%d", pingColor, GetPlayerPing(playerid));
	PlayerTextDrawSetString(playerid, Textdraw_Info, buff);
}

// (( Callbacks ))============================================================//
main()
{
	new lDay, lMonth, lYear;
	new lHour, lMinute, lSecond;
	
	getdate(lYear, lMonth, lDay);
	gettime(lHour, lMinute, lSecond);
	
	printf("Server status: [ONLINE]");
	printf(" ");
	printf("Timestamp: %i-%i-%i | %i:%i:%i", lYear, lMonth, lDay, lHour, lMinute, lSecond);
	printf("-------------------------------------");
}

public OnGameModeInit()
{
	printf("Gamemode");
    printf("---------------");
    printf("Immortal Home Server || Gamemode " GAMEMODE_NAME " v" GAMEMODE_VERSION);
    printf("--- Initiliazing...");
    
    new loaded = 0;

    // Server settings
	SetWeather(18);
	UsePlayerPedAnims();
	AllowInteriorWeapons(1);
	EnableStuntBonusForAll(0);
	ShowPlayerMarkers(2);
	ShowNameTags(1);
	SetNameTagDrawDistance(25.0);
	
	SendRconCommand("hostname " SERVER_HOSTNAME);
	SendRconCommand("mapname " SERVER_MAPNAME);
	SendRconCommand("weburl " SERVER_WEBURL);
	
	SetGameModeText(GAMEMODE_NAME " (v" GAMEMODE_VERSION ")");
	printf("  - Server settings loaded.");
	loaded++;
	
	// Loading all skins
	AddPlayerClass(292, 1958.3783, 1343.1572, 15.3746, 269.1425, 0, 0, 0, 0, 0, 0);
	AddPlayerClass(191, 1958.3783, 1343.1572, 15.3746, 269.1425, 0, 0, 0, 0, 0, 0);
	AddPlayerClass(295, 1958.3783, 1343.1572, 15.3746, 269.1425, 0, 0, 0, 0, 0, 0);
	AddPlayerClass(214, 1958.3783, 1343.1572, 15.3746, 269.1425, 0, 0, 0, 0, 0, 0);
	AddPlayerClass(230, 1958.3783, 1343.1572, 15.3746, 269.1425, 0, 0, 0, 0, 0, 0);
	AddPlayerClass(198, 1958.3783, 1343.1572, 15.3746, 269.1425, 0, 0, 0, 0, 0, 0);
	AddPlayerClass(217, 1958.3783, 1343.1572, 15.3746, 269.1425, 0, 0, 0, 0, 0, 0);
	AddPlayerClass(211, 1958.3783, 1343.1572, 15.3746, 269.1425, 0, 0, 0, 0, 0, 0);
	AddPlayerClass(186, 1958.3783, 1343.1572, 15.3746, 269.1425, 0, 0, 0, 0, 0, 0);
	AddPlayerClass(192, 1958.3783, 1343.1572, 15.3746, 269.1425, 0, 0, 0, 0, 0, 0);
	AddPlayerClass(170, 1958.3783, 1343.1572, 15.3746, 269.1425, 0, 0, 0, 0, 0, 0);
	AddPlayerClass(141, 1958.3783, 1343.1572, 15.3746, 269.1425, 0, 0, 0, 0, 0, 0);
	AddPlayerClass(101, 1958.3783, 1343.1572, 15.3746, 269.1425, 0, 0, 0, 0, 0, 0);
	AddPlayerClass(93, 1958.3783, 1343.1572, 15.3746, 269.1425, 0, 0, 0, 0, 0, 0);
	AddPlayerClass(115, 1958.3783, 1343.1572, 15.3746, 269.1425, 0, 0, 0, 0, 0, 0);
	AddPlayerClass(85, 1958.3783, 1343.1572, 15.3746, 269.1425, 0, 0, 0, 0, 0, 0);
	printf("  - Player skins loaded.");
	loaded++;
	
	// Cars
	AddStaticVehicle(451, 2040.0520, 1319.2799, 10.3779, 183.2439, 16, 16);
	AddStaticVehicle(429, 2040.5247, 1359.2783, 10.3516, 177.1306, 13, 13);
	AddStaticVehicle(421, 2110.4102, 1398.3672, 10.7552, 359.5964, 13, 13);
	AddStaticVehicle(411, 2074.9624, 1479.2120, 10.3990, 359.6861, 64, 64);
	AddStaticVehicle(477, 2075.6038, 1666.9750, 10.4252, 359.7507, 94, 94);
	AddStaticVehicle(541, 2119.5845, 1938.5969, 10.2967, 181.9064, 22, 22);
	AddStaticVehicle(541, 1843.7881, 1216.0122, 10.4556, 270.8793, 60, 1);
	AddStaticVehicle(402, 1944.1003, 1344.7717, 8.9411, 0.8168, 30, 30);
	AddStaticVehicle(402, 1679.2278, 1316.6287, 10.6520, 180.4150, 90, 90);
	AddStaticVehicle(415, 1685.4872, 1751.9667, 10.5990, 268.1183, 25, 1);
	AddStaticVehicle(411, 2034.5016, 1912.5874, 11.9048, 0.2909, 123, 1);
	AddStaticVehicle(411, 2172.1682, 1988.8643, 10.5474, 89.9151, 116, 1);
	AddStaticVehicle(429, 2245.5759, 2042.4166, 10.5000, 270.7350, 14, 14);
	AddStaticVehicle(477, 2361.1538, 1993.9761, 10.4260, 178.3929, 101, 1);
	AddStaticVehicle(550, 2221.9946, 1998.7787, 9.6815, 92.6188, 53, 53);
	AddStaticVehicle(558, 2243.3833, 1952.4221, 14.9761, 359.4796, 116, 1);
	AddStaticVehicle(587, 2276.7085, 1938.7263, 31.5046, 359.2321, 40, 1);
	AddStaticVehicle(587, 2602.7769, 1853.0667, 10.5468, 91.4813, 43, 1);
	AddStaticVehicle(603, 2610.7600, 1694.2588, 10.6585, 89.3303, 69, 1);
	AddStaticVehicle(587, 2635.2419, 1075.7726, 10.5472, 89.9571, 53, 1);
	AddStaticVehicle(437, 2577.2354, 1038.8063, 10.4777, 181.7069, 35, 1);
	AddStaticVehicle(535, 2039.1257, 1545.0879, 10.3481, 359.6690, 123, 1);
	AddStaticVehicle(535, 2009.8782, 2411.7524, 10.5828, 178.9618, 66, 1);
	AddStaticVehicle(429, 2010.0841, 2489.5510, 10.5003, 268.7720, 1, 2);
	AddStaticVehicle(415, 2076.4033, 2468.7947, 10.5923, 359.9186, 36, 1);
	AddStaticVehicle(487, 2093.2754, 2414.9421, 74.7556, 89.0247, 26, 57);
	AddStaticVehicle(506, 2352.9026, 2577.9768, 10.5201, 0.4091, 7, 7);
	AddStaticVehicle(506, 2166.6963, 2741.0413, 10.5245, 89.7816, 52, 52);
	AddStaticVehicle(411, 1960.9989, 2754.9072, 10.5473, 200.4316, 112, 1);
	AddStaticVehicle(429, 1919.5863, 2760.7595, 10.5079, 100.0753, 2, 1);
	AddStaticVehicle(415, 1673.8038, 2693.8044, 10.5912, 359.7903, 40, 1);
	AddStaticVehicle(402, 1591.0482, 2746.3982, 10.6519, 172.5125, 30, 30);
	AddStaticVehicle(603, 1580.4537, 2838.2886, 10.6614, 181.4573, 75, 77);
	AddStaticVehicle(550, 1555.2734, 2750.5261, 10.6388, 91.7773, 62, 62);
	AddStaticVehicle(535, 1455.9305, 2878.5288, 10.5837, 181.0987, 118, 1);
	AddStaticVehicle(477, 1537.8425, 2578.0525, 10.5662, 0.0650, 121, 1);
	AddStaticVehicle(451, 1433.1594, 2607.3762, 10.3781, 88.0013, 16, 16);
	AddStaticVehicle(603, 2223.5898, 1288.1464, 10.5104, 182.0297, 18, 1);
	AddStaticVehicle(558, 2451.6707, 1207.1179, 10.4510, 179.8960, 24, 1);
	AddStaticVehicle(550, 2461.7253, 1357.9705, 10.6389, 180.2927, 62, 62);
	AddStaticVehicle(558, 2461.8162, 1629.2268, 10.4496, 181.4625, 117, 1);
	AddStaticVehicle(477, 2395.7554, 1658.9591, 10.5740, 359.7374, 0, 1);
	AddStaticVehicle(404, 1553.3696, 1020.2884, 10.5532, 270.6825, 119, 50);
	AddStaticVehicle(400, 1380.8304, 1159.1782, 10.9128, 355.7117, 123, 1);
	AddStaticVehicle(418, 1383.4630, 1035.0420, 10.9131, 91.2515, 117, 227);
	AddStaticVehicle(404, 1445.4526, 974.2831, 10.5534, 1.6213, 109, 100);
	AddStaticVehicle(400, 1704.2365, 940.1490, 10.9127, 91.9048, 113, 1);
	AddStaticVehicle(404, 1658.5463, 1028.5432, 10.5533, 359.8419, 101, 101);
	AddStaticVehicle(581, 1677.6628, 1040.1930, 10.4136, 178.7038, 58, 1);
	AddStaticVehicle(581, 1383.6959, 1042.2114, 10.4121, 85.7269, 66, 1);
	AddStaticVehicle(581, 1064.2332, 1215.4158, 10.4157, 177.2942, 72, 1);
	AddStaticVehicle(581, 1111.4536, 1788.3893, 10.4158, 92.4627, 72, 1);
	AddStaticVehicle(522, 953.2818, 1806.1392, 8.2188, 235.0706, 3, 8);
	AddStaticVehicle(522, 995.5328, 1886.6055, 10.5359, 90.1048, 3, 8);
	AddStaticVehicle(521, 993.7083, 2267.4133, 11.0315, 1.5610, 75, 13);
	AddStaticVehicle(535, 1439.5662, 1999.9822, 10.5843, 0.4194, 66, 1);
	AddStaticVehicle(522, 1430.2354, 1999.0144, 10.3896, 352.0951, 6, 25);
	AddStaticVehicle(522, 2156.3540, 2188.6572, 10.2414, 22.6504, 6, 25);
	AddStaticVehicle(598, 2277.6846, 2477.1096, 10.5652, 180.1090, 0, 1);
	AddStaticVehicle(598, 2268.9888, 2443.1697, 10.5662, 181.8062, 0, 1);
	AddStaticVehicle(598, 2256.2891, 2458.5110, 10.5680, 358.7335, 0, 1);
	AddStaticVehicle(598, 2251.6921, 2477.0205, 10.5671, 179.5244, 0, 1);
	AddStaticVehicle(523, 2294.7305, 2441.2651, 10.3860, 9.3764, 0, 0);
	AddStaticVehicle(523, 2290.7268, 2441.3323, 10.3944, 16.4594, 0, 0);
	AddStaticVehicle(523, 2295.5503, 2455.9656, 2.8444, 272.6913, 0, 0);
	AddStaticVehicle(522, 2476.7900, 2532.2222, 21.4416, 0.5081, 8, 82);
	AddStaticVehicle(522, 2580.5320, 2267.9595, 10.3917, 271.2372, 8, 82);
	AddStaticVehicle(522, 2814.4331, 2364.6641, 10.3907, 89.6752, 36, 105);
	AddStaticVehicle(535, 2827.4143, 2345.6953, 10.5768, 270.0668, 97, 1);
	AddStaticVehicle(521, 1670.1089, 1297.8322, 10.3864, 359.4936, 87, 118);
	AddStaticVehicle(487, 1614.7153, 1548.7513, 11.2749, 347.1516, 58, 8);
	AddStaticVehicle(487, 1647.7902, 1538.9934, 11.2433, 51.8071, 0, 8);
	AddStaticVehicle(487, 1608.3851, 1630.7268, 11.2840, 174.5517, 58, 8);
	AddStaticVehicle(476, 1283.0006, 1324.8849, 9.5332, 275.0468, 7, 6);
	AddStaticVehicle(476, 1283.5107, 1361.3171, 9.5382, 271.1684, 1, 6);
	AddStaticVehicle(476, 1283.6847, 1386.5137, 11.5300, 272.1003, 89, 91);
	AddStaticVehicle(476, 1288.0499, 1403.6605, 11.5295, 243.5028, 119, 117);
	AddStaticVehicle(415, 1319.1038, 1279.1791, 10.5931, 0.9661, 62, 1);
	AddStaticVehicle(521, 1710.5763, 1805.9275, 10.3911, 176.5028, 92, 3);
	AddStaticVehicle(521, 2805.1650, 2027.0028, 10.3920, 357.5978, 92, 3);
	AddStaticVehicle(535, 2822.3628, 2240.3594, 10.5812, 89.7540, 123, 1);
	AddStaticVehicle(521, 2876.8013, 2326.8418, 10.3914, 267.8946, 115, 118);
	AddStaticVehicle(429, 2842.0554, 2637.0105, 10.5000, 182.2949, 1, 3);
	AddStaticVehicle(549, 2494.4214, 2813.9348, 10.5172, 316.9462, 72, 39);
	AddStaticVehicle(549, 2327.6484, 2787.7327, 10.5174, 179.5639, 75, 39);
	AddStaticVehicle(549, 2142.6970, 2806.6758, 10.5176, 89.8970, 79, 39);
	AddStaticVehicle(521, 2139.7012, 2799.2114, 10.3917, 229.6327, 25, 118);
	AddStaticVehicle(521, 2104.9446, 2658.1331, 10.3834, 82.2700, 36, 0);
	AddStaticVehicle(521, 1914.2322, 2148.2590, 10.3906, 267.7297, 36, 0);
	AddStaticVehicle(549, 1904.7527, 2157.4312, 10.5175, 183.7728, 83, 36);
	AddStaticVehicle(549, 1532.6139, 2258.0173, 10.5176, 359.1516, 84, 36);
	AddStaticVehicle(521, 1534.3204, 2202.8970, 10.3644, 4.9108, 118, 118);
	AddStaticVehicle(549, 1613.1553, 2200.2664, 10.5176, 89.6204, 89, 35);
	AddStaticVehicle(400, 1552.1292, 2341.7854, 10.9126, 274.0815, 101, 1);
	AddStaticVehicle(404, 1637.6285, 2329.8774, 10.5538, 89.6408, 101, 101);
	AddStaticVehicle(400, 1357.4165, 2259.7158, 10.9126, 269.5567, 62, 1);
	AddStaticVehicle(411, 1281.7458, 2571.6719, 10.5472, 270.6128, 106, 1);
	AddStaticVehicle(522, 1305.5295, 2528.3076, 10.3955, 88.7249, 3, 8);
	AddStaticVehicle(521, 993.9020, 2159.4194, 10.3905, 88.8805, 74, 74);
	AddStaticVehicle(415, 1512.7134, 787.6931, 10.5921, 359.5796, 75, 1);
	AddStaticVehicle(522, 2299.5872, 1469.7910, 10.3815, 258.4984, 3, 8);
	AddStaticVehicle(522, 2133.6428, 1012.8537, 10.3789, 87.1290, 3, 8);

	AddStaticVehicle(415, 2266.7336, 648.4756, 11.0053, 177.8517, 0, 1); //
	AddStaticVehicle(461, 2404.6636, 647.9255, 10.7919, 183.7688, 53, 1); //
	AddStaticVehicle(506, 2628.1047, 746.8704, 10.5246, 352.7574, 3, 3); //
	AddStaticVehicle(549, 2817.6445, 928.3469, 10.4470, 359.5235, 72, 39); //
	AddStaticVehicle(562, 1919.8829, 947.1886, 10.4715, 359.4453, 11, 1); //
	AddStaticVehicle(562, 1881.6346, 1006.7653, 10.4783, 86.9967, 11, 1); //
	AddStaticVehicle(562, 2038.1044, 1006.4022, 10.4040, 179.2641, 11, 1); //
	AddStaticVehicle(562, 2038.1614, 1014.8566, 10.4057, 179.8665, 11, 1); //
	AddStaticVehicle(562, 2038.0966, 1026.7987, 10.4040, 180.6107, 11, 1); //

	AddStaticVehicle(422, 9.1065, 1165.5066, 19.5855, 2.1281, 101, 25); //
	AddStaticVehicle(463, 19.8059, 1163.7103, 19.1504, 346.3326, 11, 11); //
	AddStaticVehicle(463, 12.5740, 1232.2848, 18.8822, 121.8670, 22, 22); //
	AddStaticVehicle(586, 69.4633, 1217.0189, 18.3304, 158.9345, 10, 1); //
	AddStaticVehicle(586, -199.4185, 1223.0405, 19.2624, 176.7001, 25, 1); //
	AddStaticVehicle(476, 325.4121, 2538.5999, 17.5184, 181.2964, 71, 77); //
	AddStaticVehicle(476, 291.0975, 2540.0410, 17.5276, 182.7206, 7, 6); //
	AddStaticVehicle(576, 384.2365, 2602.1763, 16.0926, 192.4858, 72, 1); //
	AddStaticVehicle(586, 423.8012, 2541.6870, 15.9708, 338.2426, 10, 1); //
	AddStaticVehicle(586, -244.0047, 2724.5439, 62.2077, 51.5825, 10, 1); //
	AddStaticVehicle(586, -311.1414, 2659.4329, 62.4513, 310.9601, 27, 1); //

	AddStaticVehicle(543, 596.8064, 866.2578, -43.2617, 186.8359, 67, 8); //
	AddStaticVehicle(543, 835.0838, 836.8370, 11.8739, 14.8920, 8, 90); //
	AddStaticVehicle(549, 843.1893, 838.8093, 12.5177, 18.2348, 79, 39); //
	AddStaticVehicle(400, -235.9767, 1045.8623, 19.8158, 180.0806, 75, 1); //
	AddStaticVehicle(599, -211.5940, 998.9857, 19.8437, 265.4935, 0, 1); //
	AddStaticVehicle(422, -304.0620, 1024.1111, 19.5714, 94.1812, 96, 25); //
	AddStaticVehicle(588, -290.2229, 1317.0276, 54.1871, 81.7529, 1, 1); //
	AddStaticVehicle(451, -290.3145, 1567.1534, 75.0654, 133.1694, 61, 61); //
	AddStaticVehicle(470, 280.4914, 1945.6143, 17.6317, 310.3278, 43, 0); //
	AddStaticVehicle(470, 272.2862, 1949.4713, 17.6367, 285.9714, 43, 0); //
	AddStaticVehicle(470, 271.6122, 1961.2386, 17.6373, 251.9081, 43, 0); //
	AddStaticVehicle(470, 279.8705, 1966.2362, 17.6436, 228.4709, 43, 0); //
	AddStaticVehicle(433, 277.6437, 1985.7559, 18.0772, 270.4079, 43, 0); //
	AddStaticVehicle(433, 277.4477, 1994.8329, 18.0773, 267.7378, 43, 0); //
	AddStaticVehicle(568, -441.3438, 2215.7026, 42.2489, 191.7953, 41, 29); //
	AddStaticVehicle(568, -422.2956, 2225.2612, 42.2465, 0.0616, 41, 29); //
	AddStaticVehicle(568, -371.7973, 2234.5527, 42.3497, 285.9481, 41, 29); //
	AddStaticVehicle(568, -360.1159, 2203.4272, 42.3039, 113.6446, 41, 29); //
	AddStaticVehicle(468, -660.7385, 2315.2642, 138.3866, 358.7643, 6, 6); //
	AddStaticVehicle(460, -1029.2648, 2237.2217, 42.2679, 260.5732, 1, 3); //

	AddStaticVehicle(419, 95.0568, 1056.5530, 13.4068, 192.1461, 13, 76); //
	AddStaticVehicle(429, 114.7416, 1048.3517, 13.2890, 174.9752, 1, 2); //
	AddStaticVehicle(411, -290.0065, 1759.4958, 42.4154, 89.7571, 116, 1); //
	AddStaticVehicle(522, -302.5649, 1777.7349, 42.2514, 238.5039, 6, 25); //
	AddStaticVehicle(522, -302.9650, 1776.1152, 42.2588, 239.9874, 8, 82); //
	AddStaticVehicle(533, -301.0404, 1750.8517, 42.3966, 268.7585, 75, 1); //
	AddStaticVehicle(535, -866.1774, 1557.2700, 23.8319, 269.3263, 31, 1); //
	AddStaticVehicle(550, -799.3062, 1518.1556, 26.7488, 88.5295, 53, 53); //
	AddStaticVehicle(521, -749.9730, 1589.8435, 26.5311, 125.6508, 92, 3); //
	AddStaticVehicle(522, -867.8612, 1544.5282, 22.5419, 296.0923, 3, 3); //
	AddStaticVehicle(554, -904.2978, 1553.8269, 25.9229, 266.6985, 34, 30); //
	AddStaticVehicle(521, -944.2642, 1424.1603, 29.6783, 148.5582, 92, 3); //

	AddStaticVehicle(429, -237.7157, 2594.8804, 62.3828, 178.6802, 1, 2); //
	AddStaticVehicle(463, -196.3012, 2774.4395, 61.4775, 303.8402, 22, 22); //
	AddStaticVehicle(519, -1341.1079, -254.3787, 15.0701, 321.6338, 1, 1); //
	AddStaticVehicle(519, -1371.1775, -232.3967, 15.0676, 315.6091, 1, 1); //
	AddStaticVehicle(519, 1642.9850, -2425.2063, 14.4744, 159.8745, 1, 1); //
	AddStaticVehicle(519, 1734.1311, -2426.7563, 14.4734, 172.2036, 1, 1); //

	AddStaticVehicle(415, -680.9882, 955.4495, 11.9032, 84.2754, 36, 1); //
	AddStaticVehicle(460, -816.3951, 2222.7375, 43.0045, 268.1861, 1, 3); //
	AddStaticVehicle(460, -94.6885, 455.4018, 1.5719, 250.5473, 1, 3); //
	AddStaticVehicle(460, 1624.5901, 565.8568, 1.7817, 200.5292, 1, 3); //
	AddStaticVehicle(460, 1639.3567, 572.2720, 1.5311, 206.6160, 1, 3); //
	AddStaticVehicle(460, 2293.4219, 517.5514, 1.7537, 270.7889, 1, 3); //
	AddStaticVehicle(460, 2354.4690, 518.5284, 1.7450, 270.2214, 1, 3); //
	AddStaticVehicle(460, 772.4293, 2912.5579, 1.0753, 69.6706, 1, 3); //

	AddStaticVehicle(560, 2133.0769, 1019.2366, 10.5259, 90.5265, 9, 39); //
	AddStaticVehicle(560, 2142.4023, 1408.5675, 10.5258, 0.3660, 17, 1); //
	AddStaticVehicle(560, 2196.3340, 1856.8469, 10.5257, 179.8070, 21, 1); //
	AddStaticVehicle(560, 2103.4146, 2069.1514, 10.5249, 270.1451, 33, 0); //
	AddStaticVehicle(560, 2361.8042, 2210.9951, 10.3848, 178.7366, 37, 0); //
	AddStaticVehicle(560, -1993.2465, 241.5329, 34.8774, 310.0117, 41, 29); //
	AddStaticVehicle(559, -1989.3235, 270.1447, 34.8321, 88.6822, 58, 8); //
	AddStaticVehicle(559, -1946.2416, 273.2482, 35.1302, 126.4200, 60, 1); //
	AddStaticVehicle(558, -1956.8257, 271.4941, 35.0984, 71.7499, 24, 1); //
	AddStaticVehicle(562, -1952.8894, 258.8604, 40.7082, 51.7172, 17, 1); //
	AddStaticVehicle(411, -1949.8689, 266.5759, 40.7776, 216.4882, 112, 1); //
	AddStaticVehicle(429, -1988.0347, 305.4242, 34.8553, 87.0725, 2, 1); //
	AddStaticVehicle(559, -1657.6660, 1213.6195, 6.9062, 282.6953, 13, 8); //
	AddStaticVehicle(560, -1658.3722, 1213.2236, 13.3806, 37.9052, 52, 39); //
	AddStaticVehicle(558, -1660.8994, 1210.7589, 20.7875, 317.6098, 36, 1); //
	AddStaticVehicle(550, -1645.2401, 1303.9883, 6.8482, 133.6013, 7, 7); //
	AddStaticVehicle(460, -1333.1960, 903.7660, 1.5568, 0.5095, 46, 32); //

	AddStaticVehicle(411, 113.8611, 1068.6182, 13.3395, 177.1330, 116, 1); //
	AddStaticVehicle(429, 159.5199, 1185.1160, 14.7324, 85.5769, 1, 2); //
	AddStaticVehicle(411, 612.4678, 1694.4126, 6.7192, 302.5539, 75, 1); //
	AddStaticVehicle(522, 661.7609, 1720.9894, 6.5641, 19.1231, 6, 25); //
	AddStaticVehicle(522, 660.0554, 1719.1187, 6.5642, 12.7699, 8, 82); //
	AddStaticVehicle(567, 711.4207, 1947.5208, 5.4056, 179.3810, 90, 96); //
	AddStaticVehicle(567, 1031.8435, 1920.3726, 11.3369, 89.4978, 97, 96); //
	AddStaticVehicle(567, 1112.3754, 1747.8737, 10.6923, 270.9278, 102, 114); //
	AddStaticVehicle(567, 1641.6802, 1299.2113, 10.6869, 271.4891, 97, 96); //
	AddStaticVehicle(567, 2135.8757, 1408.4512, 10.6867, 180.4562, 90, 96); //
	AddStaticVehicle(567, 2262.2639, 1469.2202, 14.9177, 91.1919, 99, 81); //
	AddStaticVehicle(567, 2461.7380, 1345.5385, 10.6975, 0.9317, 114, 1); //
	AddStaticVehicle(567, 2804.4365, 1332.5348, 10.6283, 271.7682, 88, 64); //
	AddStaticVehicle(560, 2805.1685, 1361.4004, 10.4548, 270.2340, 17, 1); //
	AddStaticVehicle(506, 2853.5378, 1361.4677, 10.5149, 269.6648, 7, 7); //
	AddStaticVehicle(567, 2633.9832, 2205.7061, 10.6868, 180.0076, 93, 64); //
	AddStaticVehicle(567, 2119.9751, 2049.3127, 10.5423, 180.1963, 93, 64); //
	AddStaticVehicle(567, 2785.0261, -1835.0374, 9.6874, 226.9852, 93, 64); //
	AddStaticVehicle(567, 2787.8975, -1876.2583, 9.6966, 0.5804, 99, 81); //
	AddStaticVehicle(411, 2771.2993, -1841.5620, 9.4870, 20.7678, 116, 1); //
	AddStaticVehicle(420, 1713.9319, 1467.8354, 10.5219, 342.8006, 6, 1); // taxi
	printf("  - Cars loaded.");
	loaded++;
	
	// Time system
	KillTimer(gTimeData[t_Timer]);
	
	gTimeData[t_Textdraw] = TextDrawCreate(547.000000, 23.000000, "00:00");
	TextDrawBackgroundColor(gTimeData[t_Textdraw], 255);
	TextDrawFont(gTimeData[t_Textdraw], 3);
	TextDrawLetterSize(gTimeData[t_Textdraw], 0.599999, 2.100000);
	TextDrawColor(gTimeData[t_Textdraw], -1);
	TextDrawSetOutline (gTimeData[t_Textdraw], 1);
	TextDrawSetProportional(gTimeData[t_Textdraw], 1);
	
	gTimeData[t_Hour] = 0, gTimeData[t_Minute] = 0;
	SetWorldTime(gTimeData[t_Hour]);
	gTimeData[t_Timer] = SetTimer("TimeUpdate", 10000, true);
	printf("  - Time system loaded.");
	loaded++;
	
	// Textdraws
	Textdraw_General = TextDrawCreate(635.000000, 430.000000, "/v /tp /account /commands /gamemode /help");
	TextDrawAlignment(Textdraw_General, 3);
	TextDrawBackgroundColor(Textdraw_General, 255);
	TextDrawFont(Textdraw_General, 3);
	TextDrawLetterSize(Textdraw_General, 0.449999, 1.299999);
	TextDrawColor(Textdraw_General, -858993409);
	TextDrawSetOutline(Textdraw_General, 1);
	TextDrawSetProportional(Textdraw_General, 1);
	TextDrawSetSelectable(Textdraw_General, 0);

	Textdraw_Announce = TextDrawCreate(162.000000, 240.000000, "- ANNOUNCEMENT: ~n~~w~Looks like server gonna halt down. Be ready everyone. We will have sex after restart!");
	TextDrawAlignment(Textdraw_Announce, 3);
	TextDrawBackgroundColor(Textdraw_Announce, 255);
	TextDrawFont(Textdraw_Announce, 3);
	TextDrawLetterSize(Textdraw_Announce, 0.470000, 1.100000);
	TextDrawColor(Textdraw_Announce, 576030975);
	TextDrawSetOutline(Textdraw_Announce, 1);
	TextDrawSetProportional(Textdraw_Announce, 1);
	TextDrawUseBox(Textdraw_Announce, 1);
	TextDrawBoxColor(Textdraw_Announce, 150);
	TextDrawTextSize(Textdraw_Announce, 0.000000, 0.000000);
	TextDrawSetSelectable(Textdraw_Announce, 0);
	printf("  - Textdraws loaded.");
	loaded++;
	
	printf("  Total loaded: %i", loaded);
	return 1;
}

public OnGameModeExit()
{
	printf("-------------------------------------");
    printf("--- Termination initialized.");
    printf(" ");
	
	KillTimer(gTimeData[t_Timer]);
	TextDrawDestroy(gTimeData[t_Textdraw]);
	printf("  - Time system unloaded.");
	
	TextDrawDestroy(Textdraw_General);
	printf("  - Textdraws unloaded.");
	
	printf("Server status: [OFFLINE]");
	printf("-------------------------------------");
	printf("# Good night sweet child.");
	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
	PlayerPlaySound(playerid, 1062, 0, 0, 0);
	SetPlayerPos(playerid, 2194.02, 1200.45, 10.82);
	SetPlayerFacingAngle(playerid, 355.0);
	SetPlayerCameraPos(playerid, 2194.12, 1206.29, 10.82);
	SetPlayerCameraLookAt(playerid, 2194.02, 1200.45, 10.82);
	return 1;
}

public OnPlayerConnect(playerid)
{
	// Name check
	if(!strcmp(getName(playerid), "con", true) || !strcmp(getName(playerid), "immortal", true))
	{
		SendInfoMessage(playerid, "Your name not allowed, bye bye!");
		KickPlayer(playerid);
	}
	
	// Name color
	new rand = random(sizeof(gPlayerColors));
	gPlayerRandomColor[playerid] = gPlayerColors[rand];
	SetPlayerColor(playerid, gPlayerRandomColor[playerid]);
	
	// Account system
	new buff[MAX_PLAYER_NAME + 128];
	if(fexist(GetPlayerFile(playerid)))
	{
		gPlayerData[playerid][p_Exist] = true;
		INI_ParseFile(GetPlayerFile(playerid), "userFunction_%s", .bExtra = true, .extra = playerid);
		
		if(gPlayerData[playerid][p_Banned] == 1 && strcmp(getName(playerid), "trowbridge") != 0)
		{
			format(buff, sizeof(buff), "{cccccc}Welcome.\nLooks like your account {225588}banned.\n{cccccc}You cannot enter the game.\n\nSorry.", getName(playerid));
			ShowPlayerDialog(playerid, DID_MSGBOX, DIALOG_STYLE_MSGBOX, "Banned ;_;", buff, ":(", "");
			KickPlayer(playerid);
		}
		else
		{
			format(buff, sizeof(buff), "{cccccc}Welcome, {225588}%s{cccccc}!\nIt's an honor to see you here. Please, go on and login to your account:", getName(playerid));
			ShowPlayerDialog(playerid, DID_ACCOUNTS, DIALOG_STYLE_PASSWORD, "Login panel --", buff, "Login", "Quit");
		}
	} 
	else 
	{
		gPlayerData[playerid][p_Exist] = false;
		SendInfoMessage(playerid, "Welcome to game, you can create account with \"/register\" command.");
		SendInfoMessage(playerid, "Feel newbie? Don't be afraid! You can always use \"/help\" command!");
	}
	
	// Textdraws
	Textdraw_Info = CreatePlayerTextDraw(playerid,635.000000, 414.000000, " ");
	PlayerTextDrawAlignment(playerid,Textdraw_Info, 3);
	PlayerTextDrawBackgroundColor(playerid,Textdraw_Info, 255);
	PlayerTextDrawFont(playerid,Textdraw_Info, 3);
	PlayerTextDrawLetterSize(playerid,Textdraw_Info, 0.449999, 1.299999);
	PlayerTextDrawColor(playerid,Textdraw_Info, -858993409);
	PlayerTextDrawSetOutline(playerid,Textdraw_Info, 1);
	PlayerTextDrawSetProportional(playerid,Textdraw_Info, 1);
	PlayerTextDrawSetSelectable(playerid,Textdraw_Info, 0);
	
	// Create player timer
	playerTimer[playerid] = SetTimerEx("PlayerUpdateTimer", 8000, 1, "i", playerid);
	
	// Message to everyone
	format(buff, sizeof(buff), "%s(%i) {cccccc}entered to game.", getName(playerid), playerid);
	SendMessageToAll(buff);
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	// Account check & saving data
	if(gPlayerData[playerid][p_Exist] == 1 && gPlayerData[playerid][p_LoggedIn] == 1)
	{
		PlayerSave(playerid);
		gPlayerData[playerid][p_LoggedIn] = 0;
	}
	
	// Deleting textdraws
	PlayerTextDrawDestroy(playerid, Textdraw_Info);
	
	// Kill player timer
	KillTimer(playerTimer[playerid]);
	
	// Message to everyone
	new buff[MAX_PLAYER_NAME + 48];
	new disconnectReasons[3][] = { "Timeout/Crash", "Quit", "Kick/Ban" };
	
	format(buff, sizeof(buff), "%s(%i) {cccccc}left the server {225588}(%s){cccccc}.", getName(playerid), playerid, disconnectReasons[reason]);
	SendMessageToAll(buff);
	return 1;
}

public OnPlayerSpawn(playerid)
{
	PlayerPlaySound(playerid, 1063, 0, 0, 0);
	
	new rand = random(sizeof(gRandomSpawnPos));
	SetPlayerPos(playerid, gRandomSpawnPos[rand][0], gRandomSpawnPos[rand][1], gRandomSpawnPos[rand][2]);
	
	// Textdraws
	TextDrawShowForPlayer(playerid, gTimeData[t_Textdraw]);
	TextDrawShowForPlayer(playerid, Textdraw_General);
	PlayerTextDrawShow(playerid, Textdraw_Info);
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	SendDeathMessage(killerid, playerid, reason);
	
	if(gPlayerData[playerid][p_Exist] == 1)
	{
		gPlayerData[playerid][p_Deaths]++;
	}
	
	if(gPlayerData[killerid][p_Exist] == 1)
	{
		gPlayerData[killerid][p_Kills]++;
	}
	
	TextDrawHideForPlayer(playerid, Textdraw_General);
	PlayerTextDrawHide(playerid, Textdraw_Info);
	return 1;
}

public OnVehicleSpawn(vehicleid)
{
	return 1;
}

public OnVehicleDeath(vehicleid, killerid)
{
	return 1;
}

public OnPlayerText(playerid, text[])
{
	if(strlen(text) < 48)
	{
		new msg[128 + MAX_PLAYER_NAME];
		format(msg, sizeof(msg), "%s{666666}({cccccc}%i{666666}){cccccc}: %s", getName(playerid), playerid, text);
		SendClientMessageToAll(gPlayerRandomColor[playerid], msg);
	}
	else
	{
		new msg_part1[128 + MAX_PLAYER_NAME], msg_part2[128 - 48];
		strmid(msg_part1, text, 0, 48);
		strmid(msg_part2, text, 48, 128);
		
		format(msg_part1, sizeof(msg_part1), "%s{666666}({cccccc}%i{666666}){cccccc}: %s", getName(playerid), playerid, msg_part1);
		SendClientMessageToAll(gPlayerRandomColor[playerid], msg_part1);
		SendClientMessageToAll(0xCCCCCCFF, msg_part2);
	}
    SetPlayerChatBubble(playerid, text, 0xCCCCCCFF, 100.0, 5000);
	return 0;
}

public OnPlayerCommandText(playerid, cmdtext[])
{
	printf("[command] %s entered \"%s\" command.", getName(playerid), cmdtext); // For command logging
	
	// General commands:
	if(!strcmp("/help", cmdtext, true))
	{
	    ShowPlayerDialog(playerid, DID_HELP, DIALOG_STYLE_LIST, "Help menu --",
			"I am a new player!\nWhat is this server?\nI found a bug!\nI want to be in the team!\n{FF0000}Select something --", "Select", "Close");
		return 1;
	}
	
	if(!strcmp("/gamemode", cmdtext, true))
	{
	    new temp[1024];
	    format(temp, sizeof(temp), "%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s", gameModeDialog[0], gameModeDialog[1], gameModeDialog[2]);
	    ShowPlayerDialog(playerid, DID_GAMEMODE, DIALOG_STYLE_LIST, "System menu --", temp, "Select", "Close");
		return 1;
	}
	
	if(!strcmp("/changelog", cmdtext, true))
	{
	    new temp[1024];
	    format(temp, sizeof(temp), "{cccccc}%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s", changeLog[0][0], changeLog[0][1], changeLog[0][2], changeLog[0][3], changeLog[0][4]);
	    ShowPlayerDialog(playerid, DID_CHANGELOG, DIALOG_STYLE_MSGBOX, "Changelog --", temp, "Close", "");
		return 1;
	}
	
    if(!strcmp("/iwantyou", cmdtext, true))
	{
	    ShowPlayerDialog(playerid, DID_IWANTYOU, DIALOG_STYLE_MSGBOX, "Team menu --", 
			"{cccccc}Welcome to \"I want you!\" section!\nSo, looks like you decided to join our team,\nOur team, which release new gamemodes and manages the server is now only have " SERVER_TEAM " person.\nSo, this is too much work for perfection.\nIf you select the \"Yes i'm.\" you will sending to job selection page and after that e-mail page.\nare you ready for next step?", "Yes, i'm.", "Not really.");
		return 1;
	}
	
	if(!strcmp("/commands", cmdtext, true))
	{
	    new temp[1024];
	    format(temp, sizeof(temp), "{cccccc}%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s", commandList[0], commandList[1], commandList[2], commandList[3], commandList[4], commandList[5], commandList[6], commandList[7]);
	    ShowPlayerDialog(playerid, DID_MSGBOX, DIALOG_STYLE_MSGBOX, "Command list --", temp, "Close", "");
		return 1;
	}
	
	// Helpful commands:
	if(!strcmp("/killme", cmdtext, true) || !strcmp("/die", cmdtext, true) || !strcmp("/kill", cmdtext, true) || !strcmp("/dead", cmdtext, true))
	{
	    SendInfoMessage(playerid, "You want to die.");
	    SetPlayerHealth(playerid, 0.0);
		return 1;
	}
	
	if(!strcmp("/mypos", cmdtext, true))
	{
		new Float:playerPos[3];
		new Float:playerAngle;
		new buff[70];
		
		GetPlayerPos(playerid, playerPos[0], playerPos[1], playerPos[2]);
		GetPlayerFacingAngle(playerid, playerAngle);
		format(buff, sizeof(buff), "Your position is: %.2f, %.2f, %.2f and Facing angle: %.2f", playerPos[0], playerPos[1], playerPos[2], playerAngle);
		SendClientMessage(playerid, 0xCCCCCCFF, buff);
		return 1;
	}
	
	if(!strcmp("/clear", cmdtext, true))
	{
		for(new i = 0; i < 32; i++)
			SendClientMessage(playerid, 0xCCCCCCFF, "");
		return 1;
	}
	
	// Account system
	if(!strcmp("/register", cmdtext, true))
	{
		if(gPlayerData[playerid][p_Exist] == 1) return SendErrorMessage(playerid, "You already have a account!");
		ShowPlayerDialog(playerid, DID_ACCOUNTS+1, DIALOG_STYLE_PASSWORD, "Register for account", "{cccccc}Please select a password for yourself.\nDon't be afraid about making mistakes, we will ask you {225588}twice{cccccc}:", "Register", "Cancel");
		return 1;
	}
	
	if(!strcmp("/account", cmdtext, true))
	{
		ShowPlayerDialog(playerid, DID_ACCOUNTS+3, DIALOG_STYLE_LIST, "Account panel --", "Show status\nChange nickname\nChange password", "Select", "Close");
		return 1;
	}
	
	dcmd(kick, 4, cmdtext);
	dcmd(ban, 3, cmdtext);
	dcmd(banip, 5, cmdtext);
	dcmd(makeadmin, 9, cmdtext);
	dcmd(announce, 8, cmdtext);
	
	return SendErrorMessage(playerid, "Command not found. Maybe a little help from \"/help\" can help?");
}

// Admin commands
dcmd_kick(playerid, params[])
{
	new id, reason[64];
	if(gPlayerData[playerid][p_Adminity] < ADMINITY_KICK_LEVEL) SendErrorMessage(playerid, "You can't use this command.");
	else if(sscanf(params, "uS(No reason entered.)[64]", id, reason)) SendUsageMessage(playerid, "/kick <playerid/partname> <reason*>");
	else if(id == INVALID_PLAYER_ID) SendErrorMessage(playerid, "Player not found.");
	else if(gPlayerData[id][p_Adminity] >= gPlayerData[playerid][p_Adminity] && id != playerid) SendErrorMessage(playerid, "You can't kick this admin.");
	else
	{
		new buff[256];
		format(buff, sizeof(buff), "{cccccc}Kick reason: {ff3333}%s\n{cccccc}Kick datetime: {ff3333}%s\n\n{ccccee}If you're thinking something is wrong, share it on our forum.\nForum URL: %s", reason, getDateTimeOnString(), SERVER_FORUMURL);
		ShowPlayerDialog(id, DID_MSGBOX, DIALOG_STYLE_MSGBOX, "Kicked ;_;", buff, ":(", "");
		KickPlayer(id);
	}
	return 1;
}

dcmd_ban(playerid, params[])
{
	new id, reason[64];
	if(gPlayerData[playerid][p_Adminity] < ADMINITY_BAN_LEVEL) SendErrorMessage(playerid, "You can't use this command.");
	else if(sscanf(params, "uS(No reason entered.)[64]", id, reason)) SendUsageMessage(playerid, "/ban <playerid/partname> <reason*>");
	else if(id == INVALID_PLAYER_ID) SendErrorMessage(playerid, "Player not found.");
	else if(gPlayerData[id][p_Adminity] >= gPlayerData[playerid][p_Adminity] && id != playerid) SendErrorMessage(playerid, "You can't ban this admin.");
	else
	{
		new buff[256];
		format(buff, sizeof(buff), "{cccccc}Ban reason: {ff3333}%s\n{cccccc}Ban datetime: {ff3333}%s\n\n{ccccee}If you're thinking something is wrong, share it on our forum.\nForum URL: %s", reason, getDateTimeOnString(), SERVER_FORUMURL);
		ShowPlayerDialog(id, DID_MSGBOX, DIALOG_STYLE_MSGBOX, "Banned ;_;", buff, ":(", "");
		gPlayerData[id][p_Banned] = 1;
		KickPlayer(id);
	}
	return 1;
}

dcmd_banip(playerid, params[])
{
	new id, reason[64];
	if(gPlayerData[playerid][p_Adminity] < ADMINITY_BANIP_LEVEL) SendErrorMessage(playerid, "You can't use this command.");
	else if(sscanf(params, "uS(No reason entered.)[64]", id, reason)) SendUsageMessage(playerid, "/banip <playerid/partname> <reason*>");
	else if(id == INVALID_PLAYER_ID) SendErrorMessage(playerid, "Player not found.");
	else if(gPlayerData[id][p_Adminity] >= gPlayerData[playerid][p_Adminity] && id != playerid) SendErrorMessage(playerid, "You can't ban this admin's ip address.");
	else
	{
		new buff[256];
		format(buff, sizeof(buff), "{cccccc}Ban reason: {ff3333}%s\n{cccccc}Ban datetime: {ff3333}%s\n\n{ccccee}If you're thinking something is wrong, share it on our forum.\nForum URL: %s", reason, getDateTimeOnString(), SERVER_FORUMURL);
		ShowPlayerDialog(id, DID_MSGBOX, DIALOG_STYLE_MSGBOX, "Banned ;_;", buff, ":(", "");
		BanPlayer(id, reason);
	}
	return 1;
}

dcmd_makeadmin(playerid, params[])
{
	new id, level;
	if(gPlayerData[playerid][p_Adminity] < ADMINITY_MAKE_LEVEL) SendErrorMessage(playerid, "You can't use this command.");
	else if(sscanf(params, "ui", id, level)) SendUsageMessage(playerid, "/makeadmin <playerid/partname> <level>");
	else if(id == INVALID_PLAYER_ID) SendErrorMessage(playerid, "Player not found.");
	else if(level < 0 || level > 5)	SendErrorMessage(playerid, "You can only use 0-5 for level.");
	else if(gPlayerData[id][p_Adminity] >= gPlayerData[playerid][p_Adminity] && id != playerid) SendErrorMessage(playerid, "You can't change this admin's level.");
	else
	{
		new buff[128];
		format(buff, sizeof(buff), "» INFO: {cccccc}%s's level changed from %i to %i.", getName(id), gPlayerData[id][p_Adminity], level);
		SendClientMessage(playerid, 0x00A2F6AA, buff);
		format(buff, sizeof(buff), "» INFO: {cccccc}Your level changed from %i to %i by %s.", gPlayerData[id][p_Adminity], level, getName(playerid));
		SendClientMessage(id, 0x00A2F6AA, buff);
		
		gPlayerData[id][p_Adminity] = level;
	}
	return 1;
}

dcmd_announce(playerid, params[])
{
	new text[128], time;
	if(gPlayerData[playerid][p_Adminity] < ADMINITY_ANNOUNCE_LEVEL) SendErrorMessage(playerid, "You can't use this command.");
	else if(sscanf(params, "s[128]I(3)", text, time)) SendUsageMessage(playerid, "/announce <text> <time (second)>");
	else if(!text[0]) SendErrorMessage(playerid, "You should enter a text.");
	else
	{
		KillTimer(AnnounceTimer);
		new buff[88];
		format(buff, sizeof(buff), "announcement -- ~n~~w~%s", text);
		TextDrawSetString(Textdraw_Announce, buff);
		ShowAnnounce(time);
	}
	return 1;
}

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid)
{
	return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
	return 1;
}

public OnPlayerEnterCheckpoint(playerid)
{
	return 1;
}

public OnPlayerLeaveCheckpoint(playerid)
{
	return 1;
}

public OnPlayerEnterRaceCheckpoint(playerid)
{
	return 1;
}

public OnPlayerLeaveRaceCheckpoint(playerid)
{
	return 1;
}

public OnRconCommand(cmd[])
{
	return 1;
}

public OnPlayerRequestSpawn(playerid)
{
	return 1;
}

public OnObjectMoved(objectid)
{
	return 1;
}

public OnPlayerObjectMoved(playerid, objectid)
{
	return 1;
}

public OnPlayerPickUpPickup(playerid, pickupid)
{
	return 1;
}

public OnVehicleMod(playerid, vehicleid, componentid)
{
	return 1;
}

public OnVehiclePaintjob(playerid, vehicleid, paintjobid)
{
	return 1;
}

public OnVehicleRespray(playerid, vehicleid, color1, color2)
{
	return 1;
}

public OnPlayerSelectedMenuRow(playerid, row)
{
	return 1;
}

public OnPlayerExitedMenu(playerid)
{
	return 1;
}

public OnPlayerInteriorChange(playerid, newinteriorid, oldinteriorid)
{
	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	return 1;
}

public OnRconLoginAttempt(ip[], password[], success)
{
	return 1;
}

public OnPlayerUpdate(playerid)
{
	return 1;
}

public OnPlayerStreamIn(playerid, forplayerid)
{
	return 1;
}

public OnPlayerStreamOut(playerid, forplayerid)
{
	return 1;
}

public OnVehicleStreamIn(vehicleid, forplayerid)
{
	return 1;
}

public OnVehicleStreamOut(vehicleid, forplayerid)
{
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	// Help dialogs
	if(dialogid == DID_HELP && response)
	{
	    switch(listitem)
	    {
	        case 0:
	        {
	            ShowPlayerDialog(playerid, DID_HELP+1, DIALOG_STYLE_MSGBOX, "Help menu | I'm a new player! --",
					"{cccccc}So, you are a new player. Hrm. Welcome!\nYou seems concerned, don't worry, i will helpful!\n\nFirst of all, this gamemode (which is decide to every action's consequences) is a free-type gamemode with some mini-games.\nYou can do what you want. (Except things in \"/rules\").\nYou can kill someone, get their some money by that, buy a house, anything in the gamemode.\nIf you want specific info about a system, you can use \"/gamemode\" command. Also you can see changes from \"/changelog\"",
					"Go back", "Close");
	        }
	        
	        case 1:
	        {
	            ShowPlayerDialog(playerid, DID_HELP+2, DIALOG_STYLE_MSGBOX, "Help menu | What is this server? --",
					"{cccccc}This server is 'Immortal Home Server'. Running home-made gamemode which named " GAMEMODE_NAME "\nThe server idea start as a personal development project. After a 1 year break, the project handed again.\nServer runs in home machine, so can be slow.\nYou can find more info at \"/changelog\" and \"/gamemode\"\nStay tuned for more feature.",
					"Go back", "Close");
	        }
	        
	        case 2:
	        {
	            ShowPlayerDialog(playerid, DID_HELP+3, DIALOG_STYLE_MSGBOX, "Help menu | I found a bug! --",
					"{cccccc}Well, if you want to help us, you can always use \"/bugreport\" command for bugs.\nAnd if we handle the bug and you're the one who say the bug first, you can get in-game reward.\nPretty good system, isn't it?",
					"Go back", "Close");
	        }

	        case 3:
	        {
	            ShowPlayerDialog(playerid, DID_HELP+4, DIALOG_STYLE_MSGBOX, "Help menu | I want to be in the team! --", 
					"{cccccc}You can try your chance with \"/iwantyou\"\nAll your need is an account if you don't have one yet and giving some information.\nFirst you decide your job. Then your second job (if you want).\nAt the end you give a some info and starting to wait for a superuser to accept or deny you.",
					"Go back", "Close");
	        }
			
			case 4:
			{
				ShowPlayerDialog(playerid, DID_HELP, DIALOG_STYLE_LIST, "Help menu --", "I am a new player!\nWhat is this server?\nI found a bug!\nI want to be in the team!\n{FF0000}Select something --", "Select", "Close");
			}
	    }
	}
	
	if(dialogid == DID_HELP+1 || dialogid == DID_HELP+2 || dialogid == DID_HELP+3 || dialogid == DID_HELP+4)
	{
	    if(response)
	    {
	        ShowPlayerDialog(playerid, DID_HELP, DIALOG_STYLE_LIST, "Help menu --",
				"I am a new player!\nWhat is this server?\nI found a bug!\nI want to be in the team!\n{FF0000}Select something --", "Select", "Close");
		}
	}
	
	if(dialogid == DID_IWANTYOU && response)
	{
	    ShowPlayerDialog(playerid, DID_IWANTYOU+1, DIALOG_STYLE_LIST, "Team menu --",
	            "{FF3333}Which position do you want? [Your primary selection]\nServer administrator\nWebpage programmer\nWeb administrator\nMapper\nPawn coder\nTranslation & design\nTester\n((Go back))", "Select", "Cancel");
 	}
 	
 	if(dialogid == DID_IWANTYOU+1 && response)
 	{
 	    switch(listitem)
 	    {
 	        case 0:
 	        {
 	        	ShowPlayerDialog(playerid, DID_IWANTYOU+1, DIALOG_STYLE_LIST, "Team menu --",
	            	"{FF3333}Which position do you want? [Your primary selection]\nServer administrator\nWebpage programmer\nWeb administrator\nMapper\nPawn coder\nTranslation & design\nTester\n((Go back))", "Select", "Cancel");
 			}
 	        
 	        case 1:
 	        {
 	        	ShowPlayerDialog(playerid, DID_IWANTYOU+2, DIALOG_STYLE_LIST, "Team menu --",
	            	"{FF3333}Which position do you want? [Your primary selection]\nServer administrator\nWebpage programmer\nWeb administrator\nMapper\nPawn coder\nTranslation & design\nTester\n((Go back))", "Select", "Cancel");
 			}
 	        
 	        case 2:
 	        {
 	        	ShowPlayerDialog(playerid, DID_IWANTYOU+2, DIALOG_STYLE_LIST, "Team menu --",
	            	"{FF3333}Which position do you want? [Your primary selection]\nServer administrator\nWebpage programmer\nWeb administrator\nMapper\nPawn coder\nTranslation & design\nTester\n((Go back))", "Select", "Cancel");
 			}
 	        
 	        case 3:
 	        {
          		ShowPlayerDialog(playerid, DID_IWANTYOU+2, DIALOG_STYLE_LIST, "Team menu --",
	            	"{FF3333}Which position do you want? [Your primary selection]\nServer administrator\nWebpage programmer\nWeb administrator\nMapper\nPawn coder\nTranslation & design\nTester\n((Go back))", "Select", "Cancel");
 			}
 	        
 	        case 4:
 	        {
          		ShowPlayerDialog(playerid, DID_IWANTYOU+2, DIALOG_STYLE_LIST, "Team menu --",
	            	"{FF3333}Which position do you want? [Your primary selection]\nServer administrator\nWebpage programmer\nWeb administrator\nMapper\nPawn coder\nTranslation & design\nTester\n((Go back))", "Select", "Cancel");
 			}
 	        
 	        case 5:
 	        {
          		ShowPlayerDialog(playerid, DID_IWANTYOU+2, DIALOG_STYLE_LIST, "Team menu --",
	            	"{FF3333}Which position do you want? [Your primary selection]\nServer administrator\nWebpage programmer\nWeb administrator\nMapper\nPawn coder\nTranslation & design\nTester\n((Go back))", "Select", "Cancel");
 			}
 	        
 	        case 6:
 	        {
          		ShowPlayerDialog(playerid, DID_IWANTYOU+2, DIALOG_STYLE_LIST, "Team menu --",
	            	"{FF3333}Which position do you want? [Your primary selection]\nServer administrator\nWebpage programmer\nWeb administrator\nMapper\nPawn coder\nTranslation & design\nTester\n((Go back))", "Select", "Cancel");
 			}
 	        
 	        case 7:
 	        {
          		ShowPlayerDialog(playerid, DID_IWANTYOU+2, DIALOG_STYLE_LIST, "Team menu --",
	            	"{FF3333}Which position do you want? [Your primary selection]\nServer administrator\nWebpage programmer\nWeb administrator\nMapper\nPawn coder\nTranslation & design\nTester\n((Go back))", "Select", "Cancel");
 			}
 	        
 	        case 8:
 	        {
          		ShowPlayerDialog(playerid, DID_IWANTYOU+2, DIALOG_STYLE_LIST, "Team menu --",
	            	"{FF3333}Which position do you want? [Your secondary selection]\nServer administrator\nWebpage programmer\nWeb administrator\nMapper\nPawn coder\nTranslation & design\nTester\nNo secondary choice really.\n((Go back))", "Select", "Cancel");
 			}
 	    }
 	}
 	
 	if(dialogid == DID_IWANTYOU+2 && response)
 	{
 	    switch(listitem)
 	    {
 	        case 0:
 	        {
          		ShowPlayerDialog(playerid, DID_IWANTYOU+2, DIALOG_STYLE_LIST, "Team menu --",
	            	"{FF3333}Which position do you want? [Your secondary selection]\nServer administrator\nWebpage programmer\nWeb administrator\nMapper\nPawn coder\nTranslation & design\nTester\nNo secondary choice really.\n((Go back))", "Select", "Cancel");
 			}

 	        case 1:
 	        {
 	        	ShowPlayerDialog(playerid, DID_IWANTYOU+3, DIALOG_STYLE_INPUT, "Team menu --", "Enter your e-mail address (or anything like that [except, twitter, facebook, etc.]", "Finish", "Cancel");
 			}

 	        case 2:
 	        {
 	        	ShowPlayerDialog(playerid, DID_IWANTYOU+3, DIALOG_STYLE_INPUT, "Team menu --", "Enter your e-mail address (or anything like that [except, twitter, facebook, etc.]", "Finish", "Cancel");
 			}

 	        case 3:
 	        {
 	        	ShowPlayerDialog(playerid, DID_IWANTYOU+3, DIALOG_STYLE_INPUT, "Team menu --", "Enter your e-mail address (or anything like that [except, twitter, facebook, etc.]", "Finish", "Cancel");
 			}

 	        case 4:
 	        {
 	        	ShowPlayerDialog(playerid, DID_IWANTYOU+3, DIALOG_STYLE_INPUT, "Team menu --", "Enter your e-mail address (or anything like that [except, twitter, facebook, etc.]", "Finish", "Cancel");
 			}

 	        case 5:
 	        {
 	        	ShowPlayerDialog(playerid, DID_IWANTYOU+3, DIALOG_STYLE_INPUT, "Team menu --", "Enter your e-mail address (or anything like that [except, twitter, facebook, etc.]", "Finish", "Cancel");
 			}

 	        case 6:
 	        {
 	        	ShowPlayerDialog(playerid, DID_IWANTYOU+3, DIALOG_STYLE_INPUT, "Team menu --", "Enter your e-mail address (or anything like that [except, twitter, facebook, etc.]", "Finish", "Cancel");
 			}

 	        case 7:
 	        {
 	        	ShowPlayerDialog(playerid, DID_IWANTYOU+3, DIALOG_STYLE_INPUT, "Team menu --", "Enter your e-mail address (or anything like that [except, twitter, facebook, etc.]", "Finish", "Cancel");
 			}

 	        case 8:
 	        {
 	        	ShowPlayerDialog(playerid, DID_IWANTYOU+3, DIALOG_STYLE_INPUT, "Team menu --", "Enter your e-mail address (or anything like that [except, twitter, facebook, etc.]", "Finish", "Cancel");
 			}
 			
 			case 9:
 	        {
 	        	ShowPlayerDialog(playerid, DID_IWANTYOU+1, DIALOG_STYLE_LIST, "Team menu --",
	            	"{FF3333}Which position do you want? [Your primary selection]\nServer administrator\nWebpage programmer\nWeb administrator\nMapper\nPawn coder\nTranslation & design\nTester\n((Go back))", "Select", "Cancel");
 			}
 	    }
 	}
 	
 	if(dialogid == DID_IWANTYOU+3 && response)
 	{
 	    ShowPlayerDialog(playerid, DID_MSGBOX, DIALOG_STYLE_MSGBOX, "Team menu --", "{cccccc}Well, actually this service won't work for now, so just wait..", "...", "");
	}
	
	// Account system
	switch(dialogid)
	{
		case DID_ACCOUNTS: // Login
		{
			if(response)
			{
				if(udb_hash(inputtext) == gPlayerData[playerid][p_Password])
				{
					SendInfoMessage(playerid, "Logged in succesfully.");
					gPlayerData[playerid][p_LoggedIn] = 1;
					SetPlayerScore(playerid, gPlayerData[playerid][p_Score]);
					GivePlayerMoney(playerid, gPlayerData[playerid][p_Money] - GetPlayerMoney(playerid));
				}
				else
				{
					gPlayerData[playerid][p_LoginTry]++;
					if(gPlayerData[playerid][p_LoginTry] >= 3)
					{
						ShowPlayerDialog(playerid, DID_ACCOUNTS, DIALOG_STYLE_MSGBOX, "Kicked ;_;", "{cccccc}You're not logged in.\nYou cannot enter this game with this nickname without login.\nSorry.", ":(", "");
						KickPlayer(playerid);
					}
					else
					{
						new buff[MAX_PLAYER_NAME + 128];
						format(buff, sizeof(buff), "{ff0000}Login failed. Login try: %i/%i\n{cccccc}Enter your password:", gPlayerData[playerid][p_LoginTry], SECURE_LOGINFAIL, getName(playerid));
						ShowPlayerDialog(playerid, DID_ACCOUNTS, DIALOG_STYLE_INPUT, "Login panel --", buff, "Login", "Quit");
					}
				}
			}
			else
			{
				SendErrorMessage(playerid, "Sorry, you need to login.");
				KickPlayer(playerid);
			}
		}
		
		case DID_ACCOUNTS + 1: // Register - Part 1
		{
			if(response)
			{
				if(strlen(inputtext) > 32)
				{
					ShowPlayerDialog(playerid, DID_ACCOUNTS+1, DIALOG_STYLE_PASSWORD, "Register menu --", "{FF0000}Your password should be maximum 32 character.\n{cccccc}Try again from beginning, enter new password:", "Register", "Cancel");
				}
				else if(strlen(inputtext) < 8)
				{
					ShowPlayerDialog(playerid, DID_ACCOUNTS+1, DIALOG_STYLE_PASSWORD, "Register menu --", "{FF0000}Your password should be minimum 8 character.\n{cccccc}Try again from beginning, enter new password:", "Register", "Cancel");
				}
				else
				{
					gPlayerFirstPassword[playerid] = udb_hash(inputtext);
					ShowPlayerDialog(playerid, DID_ACCOUNTS+2, DIALOG_STYLE_PASSWORD, "Register menu --", "{cccccc}Please enter your password again:", "Register", "Cancel");
				}
			}
		}
		
		case DID_ACCOUNTS + 2: // Register - Part 2
		{
			if(response)
			{
				if(gPlayerFirstPassword[playerid] == udb_hash(inputtext))
				{
					SendInfoMessage(playerid, "You're registered user now, congratulations! Type \"/account\" for account panel.");
					PlayerNew(playerid, gPlayerFirstPassword[playerid]);
					gPlayerData[playerid][p_Exist] = true;
					INI_ParseFile(GetPlayerFile(playerid), "userFunction_%s", .bExtra = true, .extra = playerid);
				}
				else
				{
					ShowPlayerDialog(playerid, DID_ACCOUNTS+1, DIALOG_STYLE_PASSWORD, "Register menu --", "{FF0000}Your passwords not match!\n{cccccc}Try again from beginning, enter new password:", "Register", "Cancel");
				}
			}
		}
		
		case DID_ACCOUNTS + 3: // Account menu
		{
			if(response)
			{
				if(gPlayerData[playerid][p_Exist] == 1)
				{
					switch(listitem)
					{
						case 0: // Get data
						{
							new tempContent[MAX_PLAYER_NAME + 144];
							if(gPlayerData[playerid][p_Adminity] > 0)
							{
								format(tempContent, sizeof(tempContent), "{cccccc}User name:\t%s\nIs admin?\t{00FF00}YES{cccccc}\nKills:\t\t%i\nDeath:\t\t%i\nScore:\t\t%i\nMoney:\t\t%i\nJoin date:\t%s\nLast login:\t%s", 
									getName(playerid), gPlayerData[playerid][p_Kills], gPlayerData[playerid][p_Deaths], gPlayerData[playerid][p_Score], gPlayerData[playerid][p_Money], gPlayerData[playerid][p_CreateDate], gPlayerData[playerid][p_LastLogin]);
							}
							else
							{
								format(tempContent, sizeof(tempContent), "{cccccc}User name:\t%s\nIs admin?\t{FF0000}NO{cccccc}\nKills:\t\t%i\nDeath:\t\t%i\nScore:\t\t%i\nMoney:\t\t%i\nJoin date:\t%s\nLast login:\t%s", 
									getName(playerid), gPlayerData[playerid][p_Kills], gPlayerData[playerid][p_Deaths], gPlayerData[playerid][p_Score], gPlayerData[playerid][p_Money], gPlayerData[playerid][p_CreateDate], gPlayerData[playerid][p_LastLogin]);
							}
						
							ShowPlayerDialog(playerid, DID_ACCOUNTS + 4, DIALOG_STYLE_MSGBOX, "Your account information", tempContent, "Go back", "Close");
						}
						
						case 1: // Change name
						{
							ShowPlayerDialog(playerid, DID_ACCOUNTS + 5, DIALOG_STYLE_INPUT, "Change your name --", "{cccccc}Enter the nickname what you want:", "Enter", "Go back"); 
						}
						
						case 2: // Change password
						{
							ShowPlayerDialog(playerid, DID_ACCOUNTS + 6, DIALOG_STYLE_PASSWORD, "Change your password --", "{cccccc}Enter your {225588}current {cccccc}password:", "Enter", "Go back"); 
						}
					}
				}
				else // Not registered? Register now!
				{
					ShowPlayerDialog(playerid, DID_ACCOUNTS+1, DIALOG_STYLE_PASSWORD, "Register for account", "{cccccc}Please select a password for yourself.\nDon't be afraid about making mistakes, we will ask you {225588}twice{cccccc}:", "Register", "Cancel");
				}
			}
		}
		
		case DID_ACCOUNTS + 4: // Account menu/Get status/Go back button
		{
			if(response)
			{
				ShowPlayerDialog(playerid, DID_ACCOUNTS+3, DIALOG_STYLE_LIST, "Account panel --", "Show status\nChange nickname\nChange password", "Select", "Close");
			}
		}
		
		case DID_ACCOUNTS + 5: // Change name
		{
			if(response)
			{
				if(fexist(inputtext))
				{
					ShowPlayerDialog(playerid, DID_ACCOUNTS + 5, DIALOG_STYLE_INPUT, "Change your name --", "{ff3333}The name you entered already using!\n{cccccc}Enter another nickname for use:", "Enter", "Go back"); 
				}
				else
				{
					if(strlen(inputtext) > MAX_PLAYER_NAME)
					{
						ShowPlayerDialog(playerid, DID_ACCOUNTS + 5, DIALOG_STYLE_INPUT, "Change your name --", "{ff3333}The name you entered is bigger than 24 character!\n{cccccc}Enter another nickname for use:", "Enter", "Go back");
					}
					else if(strlen(inputtext) < 1)
					{
						ShowPlayerDialog(playerid, DID_ACCOUNTS + 5, DIALOG_STYLE_INPUT, "Change your name --", "{ff3333}The name you entered is smaller than 1\n{cccccc}Enter another nickname for use:", "Enter", "Go back");
					}
					else
					{
						PlayerUpdateName(playerid, inputtext);
						ShowPlayerDialog(playerid, DID_MSGBOX, DIALOG_STYLE_MSGBOX, "Change your name --", "{cccccc}Your name succesfully changed.\nReconnect to server.", "Bye", "");
						KickPlayer(playerid);
					}
				}
			}
			else
			{
				ShowPlayerDialog(playerid, DID_ACCOUNTS+3, DIALOG_STYLE_LIST, "Account panel --", "Show status\nChange nickname\nChange password", "Select", "Close");
			}
		}
		
		case DID_ACCOUNTS + 6: // Change password
		{
			if(response)
			{
				if(udb_hash(inputtext) == gPlayerData[playerid][p_Password])
				{
					ShowPlayerDialog(playerid, DID_ACCOUNTS + 7, DIALOG_STYLE_PASSWORD, "Change your password --", "{cccccc}Enter your {225588}new {cccccc}password:", "Enter", "Go back"); 
				}
				else
				{
					ShowPlayerDialog(playerid, DID_ACCOUNTS + 6, DIALOG_STYLE_PASSWORD, "Change your password --", "{ff3333}You entered invalid password.\n{cccccc}Enter your {225588}current {cccccc}password:", "Enter", "Go back"); 
				}
			}
			else
			{
				ShowPlayerDialog(playerid, DID_ACCOUNTS+3, DIALOG_STYLE_LIST, "Account panel --", "Show status\nChange nickname\nChange password", "Select", "Close");
			}
		}
		
		case DID_ACCOUNTS + 7:
		{
			if(response)
			{
				if(strlen(inputtext) > 32)
				{
					ShowPlayerDialog(playerid, DID_ACCOUNTS + 6, DIALOG_STYLE_PASSWORD, "Change your password --", "Your new password bigger than 32 characters!\n{cccccc}Enter your {225588}current {cccccc}password:", "Enter", "Go back"); 
				}
				else if(strlen(inputtext) < 8)
				{
					ShowPlayerDialog(playerid, DID_ACCOUNTS + 6, DIALOG_STYLE_PASSWORD, "Change your password --", "Your new password smaller than 8 characters!\n{cccccc}Enter your {225588}current {cccccc}password:", "Enter", "Go back"); 
				}
				else
				{
					gPlayerFirstPassword[playerid] = udb_hash(inputtext);
					ShowPlayerDialog(playerid, DID_ACCOUNTS + 8, DIALOG_STYLE_PASSWORD, "Change your password --", "{cccccc}Enter your {225588}new {cccccc}password again:", "Enter", "Go back");
				} 
			}
			else
			{
				ShowPlayerDialog(playerid, DID_ACCOUNTS + 6, DIALOG_STYLE_PASSWORD, "Change your password --", "{cccccc}Enter your {225588}current {cccccc}password:", "Enter", "Go back"); 
			}
		}
		
		case DID_ACCOUNTS + 8:
		{
			if(response)
			{
				if(udb_hash(inputtext) == gPlayerFirstPassword[playerid])
				{
					gPlayerData[playerid][p_Password] = gPlayerFirstPassword[playerid];
					SendInfoMessage(playerid, "Your password succesfully changed. Have a good day!");
				}
				else
				{
					ShowPlayerDialog(playerid, DID_ACCOUNTS + 6, DIALOG_STYLE_PASSWORD, "Change your password --", "{ff3333}You entered invalid password.\n{cccccc}Enter your {225588}current {cccccc}password:", "Enter", "Go back"); 
				}
			}
			else
			{
				ShowPlayerDialog(playerid, DID_ACCOUNTS+3, DIALOG_STYLE_LIST, "Account panel --", "Show status\nChange nickname\nChange password", "Select", "Close");
			}
		}
	}
	
	return 1;
}

public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
	new tempCaption[MAX_PLAYER_NAME + 45], tempContent[MAX_PLAYER_NAME + 144];
	format(tempCaption, sizeof(tempCaption), "Profile of %s --", getName(clickedplayerid));
	
	if(gPlayerData[clickedplayerid][p_Exist] == 1)
	{
		if(gPlayerData[playerid][p_Adminity] > 0)
		{
			if(gPlayerData[clickedplayerid][p_Adminity] > 0)
			{
				format(tempContent, sizeof(tempContent), "{cccccc}User name:\t%s\nIs admin?\t{00FF00}YES{cccccc}\nKills:\t\t%i\nDeath:\t\t%i\nScore:\t\t%i\nMoney:\t\t%i\nJoin date:\t%s\nLast login:\t%s", 
					getName(clickedplayerid), gPlayerData[clickedplayerid][p_Kills], gPlayerData[clickedplayerid][p_Deaths], gPlayerData[clickedplayerid][p_Score], 
					gPlayerData[clickedplayerid][p_Money], gPlayerData[clickedplayerid][p_CreateDate], gPlayerData[clickedplayerid][p_LastLogin]);
			}
			else
			{
				format(tempContent, sizeof(tempContent), "{cccccc}User name:\t%s\nIs admin?\t{FF0000}NO{cccccc}\nKills:\t\t%i\nDeath:\t\t%i\nScore:\t\t%i\nMoney:\t\t%i\nJoin date:\t%s\nLast login:\t%s", 
					getName(clickedplayerid), gPlayerData[clickedplayerid][p_Kills], gPlayerData[clickedplayerid][p_Deaths], gPlayerData[clickedplayerid][p_Score], 
					gPlayerData[clickedplayerid][p_Money], gPlayerData[clickedplayerid][p_CreateDate], gPlayerData[clickedplayerid][p_LastLogin]);
			}
		}
		else
		{
			format(tempContent, sizeof(tempContent), "{cccccc}User name:\t%s\nKills:\t\t%i\nDeath:\t\t%i\nScore:\t\t%i\nMoney:\t\t%i\nJoin date:\t%s\nLast login:\t%s", 
				getName(clickedplayerid), gPlayerData[clickedplayerid][p_Kills], gPlayerData[clickedplayerid][p_Deaths], gPlayerData[clickedplayerid][p_Score], 
				gPlayerData[clickedplayerid][p_Money], gPlayerData[clickedplayerid][p_CreateDate], gPlayerData[clickedplayerid][p_LastLogin]);
		}
	}
	else
	{
		format(tempContent, sizeof(tempContent), "{FF0000}NO DATA FOUND.\n{cccccc}USER NOT REGISTERED USER.");
	}
	
	ShowPlayerDialog(playerid, DID_MSGBOX, DIALOG_STYLE_MSGBOX, tempCaption, tempContent, "OK", "");
	return 1;
}
