/*
Новая система розпределения авто - cartp:
0-нормальное авто без всяких дополнительных операций.
1-заспавненое авто , которее пропадает после выхода игрока из авто.
2-персональное авто , т.е. система личных авто.
3-фракционое авто, т.е. будет в системе фракций.
4-спавн авто , которое не пропадает , при выходе игрока из игры
*/
#include <a_samp>
#include <a_mysql>
#include <sscanf2>
#include <a_dialog>
#include <Pawn.CMD>
#include <streamer>
#include <regex>
#include <crashdetect>


// 0x цвета
#define COLOR_GREY 	           	                 0xAFAFAFFF // Неизвестно
#define COLOR_WHITE       	  	                 0xFFFFFFFF // Белый цвет
#define COLOR_RED 	          	                 0xE90000FF // Красный цвет
#define COLOR_SYS 		                         0xA9C4E4FF // Системный цвет
#define COLOR_GREEN           	                 0x33FF33FF // Зеленый цвет
#define COLOR_YELLOW       	  	                 0xFFFF00FF // Желтый цвет
#define COLOR_BLACK       	  	                 0x000000FF // Черный цвет
#define COLOR_BLUE 	      	  	                 0x235AFFFF // Синий
#define COLOR_BROWN       	  	                 0x943700FF // Корричневый цвет
#define COLOR_PURPLE       	  	                 0x7C48C0FF // Фиолетовый
#define COLOR_LBLUE       	  	                 0x00CDCDFF // Неизвестно
#define COLOR_PINK 	      	  	                 0xEA5CFFFF // Розовый цвет
#define COLOR_LIME                               0x10F441AA // Лаймовый цвет
#define COLOR_MAGENTA                            0xFF00FFFF // Магента
#define COLOR_CORAL                              0xFF7F50AA // Коралловый цвет
#define COLOR_GOLD                               0xB8860BAA // Золотой
#define COLOR_INDIGO                             0x4B00B0AA // Индиго
#define COLOR_TOMATO                             0xFF6347AA // Помидорный цвет
#define COLOR_GRAD1                              0xFFFFFFAA
#define COLOR_GRAD2                              0xBFC0C2FF
#define COLOR_GRAD3                              0xFFFFFFAA
#define COLOR_LIGHTRED                           0xFF6347AA // Светло-Красный
#define COLOR_GRAYWHITE                          0xB4B5B7FF // Серо-Белый
#define COLOR_LIGHTBLUE                          0x33CCFFAA // Светло-Синий (Голубой)

// html цвета
#define COL_YELLOW                               "{FFFF00}" // Желтый
#define COL_LIGHTBROWN                           "{996600}" // Светло-Корричевый
#define COL_BLACKBROWN                           "{663300}" // Темно-Корричевый
#define COL_BROWN                                "{993300}" // Корричевый
#define COL_APELS                                "{FF6600}" // Апельсиновый
#define COL_LIGHTRED                             "{FF3300}" // Светло-Красный
#define COL_BLACKRED                             "{CC0000}" // Темно-Красный
#define COL_RED                                  "{FF0000}" // Красный
#define COL_PINK                                 "{FF00CC}" // Розовый
#define COL_PURPLE                               "{CC33CC}" // Фиолетовый
#define COL_LIGHTBLUE                            "{CCCCFF}" // Светло-Синий
#define COL_BLUE                                 "{3366FF}" // Синий
#define COL_LBLUE                                "{0099FF}" // Голубой
#define COL_LIGHTGREEN                           "{00FF99}" // Светло-Зеленый
#define COL_GREEN                                "{009933}" // Зеленый
#define COL_BLACKGREEN                           "{006633}" // Темно-Зеленый
#define COL_BLIKEGREEN                           "{33FF33}" // Ярко-Зеленый
#define COL_WHITE                                "{FFFFFF}" // Белый
#define COL_LIGHTBLACK                           "{999999}" // Светло-Темный
#define COL_BLACKBLACK                           "{333333}" // Темно-Черный
#define COL_BLACK                                "{000000}" // Черный

new salt[7] = "kaktus";

#define ClearMess(%1) for(new o=0;o<10;o++) SendClientMessage(%1,-1,"")


//===================regex=================
#define IsValidEmail(%1) \
	regex_match(%1, "[a-zA-Z0-9_\\.]+@([a-zA-Z0-9\\-]+\\.)+[a-zA-Z]{2,4}")

#define IsValidRpName(%1) \
	regex_match(%1, "([A-Z]{1,1})[a-z]{2,9}+_([A-Z]{1,1})[a-z]{2,9}")
	
#define IsValidDate(%1) \
	regex_match(%1, "([0-9]{1,2})+/([0-9]{1,2})+/([0-9]{1,4})")

#define IsValidPass(%1) \
	regex_match(%1, "[a-zA-Z0-9/@ ]{1,18}")
//===================BD====================
#define sqlhost										"127.0.0.1"
#define sqluser										"root"
#define sqlpass										""
#define sqldb										"samp"
//===============MAX_Define================
#define MAX_HOUSE 255
#define MAX_CARS 255
//=========================================
//=============Player=====================
new PlayerText:Textdrawl[MAX_PLAYERS][6];
new PlayerText:Textdrawr[MAX_PLAYERS][12];
//---
#define Name(%1) PlayerInfo[%1][pName]
#define Pass(%1) PlayerInfo[%1][pPass]
#define Moneys(%1) PlayerInfo[%1][pMoney]
#define Level(%1) PlayerInfo[%1][pLevel]
//---
forward PlayerCheck(playerid);
forward LoadAkk(playerid);
//--
enum pInfo
{
	pName[MAX_PLAYER_NAME],
	pPass[65],
	pMail[24],
	pDate[10],
	pFrom,
	pLevel,
	pMoney,
	pMale,
	pSkin,
	Float:pPos[3],
	pIntW[2]
};
new PlayerInfo[MAX_PLAYERS][pInfo];
//========================================
//============Houses======================
enum hInfo
{
 	hBuy,
	hOwner[24],
 	Float:hEnt[3],//[0] - x , [1] - y , [2] - z;
	Float:hExt[3],//[0] - x , [1] - y , [2] - z;
	hInt,
	hLock,
 	hPrice,
	hLevel,
 	hCth[5],
 	hMoney
}

new HouseInfo[MAX_HOUSE][hInfo];
#define Ownerh(%1) HouseInfo[%1][hOwner]
forward HouseLoad();
new allhouse=0;
new Text3D:thbuy[MAX_HOUSE] , buyhome[MAX_HOUSE] , buyico[MAX_HOUSE];
//===========================================
//==============Vehicles=====================
static PlayerText:Textbc[MAX_PLAYERS][6];
enum cInfo
{
 	cBuy,
	cOwner[24],
	cModel,
	cLock,
 	Float:cPos[4],//[0] - x , [1] - y , [2] - z , [3] - angle;
 	cPrice,
 	cComp[13],
 	cColors[3]
 	//cMoney
}
new CarsInfo[MAX_CARS][cInfo];
forward CarsLoad();
new allcars=0;
new Text3D:tcbuy[MAX_CARS] , carsb[MAX_CARS];
new cartp[MAX_VEHICLES];
new rskin[][2] =
{
{2,9},
{3,10},
{4,11},
{5,12},
{6,13}
};
#define Ownerc(%1) CarsInfo[%1][cOwner]
new cafb[][2] =
{
{400,605},
{401,401},
{402,886},
{404,390},
{475,90},
{415,505},
{562,202},
{602,433},
{522,45},
{411,5233}
};


new NameCar[212][] = {
"Landstalker","Bravura","Buffalo","Linerunner","Pereniel","Sentinel","Dumper","Firetruck","Trashmaster","Stretch","Manana","Infernus",
"Voodoo","Pony","Mule","Cheetah","Ambulance","Leviathan","Moonbeam","Esperanto","Taxi","Washington","Bobcat","Mr Whoopee","BF Injection",
"Hunter","Premier","Enforcer","Securicar","Banshee","Predator","Bus","Rhino","Barracks","Hotknife","Trailer","Previon","Coach","Cabbie",
"Stallion","Rumpo","RC Bandit","Romero","Packer","Monster","Admiral","Squalo","Seasparrow","Pizzaboy","Tram","Trailer","Turismo","Speeder",
"Reefer","Tropic","Flatbed","Yankee","Caddy","Solair","Berkley's RC Van","Skimmer","PCJ-600","Faggio","Freeway","RC Baron","RC Raider",
"Glendale","Oceanic","Sanchez","Sparrow","Patriot","Quad","Coastguard","Dinghy","Hermes","Sabre","Rustler","ZR3 50","Walton","Regina",
"Comet","BMX","Burrito","Camper","Marquis","Baggage","Dozer","Maverick","News Chopper","Rancher","FBI Rancher","Virgo","Greenwood",
"Jetmax","Hotring","Sandking","Blista Compact","Police Maverick","Boxville","Benson","Mesa","RC Goblin","Hotring A","Hotring B",
"Bloodring Banger","Rancher","Super GT","Elegant","Journey","Bike","Mountain Bike","Beagle","Cropdust","Stunt","Tanker","RoadTrain",
"Nebula","Majestic","Buccaneer","Shamal","Hydra","FCR-900","NRG-500","HPV1000","Cement Truck","Tow Truck","Fortune","Cadrona","FBI Truck",
"Willard","Forklift","Tractor","Combine","Feltzer","Remington","Slamvan","Blade","Freight","Streak","Vortex","Vincent","Bullet","Clover",
"Sadler","Firetruck","Hustler","Intruder","Primo","Cargobob","Tampa","Sunrise","Merit","Utility","Nevada","Yosemite","Windsor","Monster A",
"Monster B","Uranus","Jester","Sultan","Stratum","Elegy","Raindance","RC Tiger","Flash","Tahoma","Savanna","Bandito","Freight","Trailer",
"Kart","Mower","Duneride","Sweeper","Broadway","Tornado","AT-400","DFT-30","Huntley","Stafford","BF-400","Newsvan","Tug","Trailer A","Emperor",
"Wayfarer","Euros","Hotdog","Club","Trailer B","Trailer C","Andromada","Dodo","RC Cam","Launch","Police Car","Police Car",
"Police Car","Police Ranger","Picador","S.W.A.T.","Alpha","Phoenix","Glendale","Sadler","L Trailer A","L Trailer B",
"Stair Trailer","Boxville","Farm Plow","U Trailer" };

//===========================================

new ses[256],pl,sesql[2056];

main()
{
	printf("|-----------------------------------------------------------------------------|");
	printf("|                            Автор: Ermakl                                    |");
	printf("|                         Game Mode -  «BIG BAZEW MOd»                        |");
	printf("|                       ...загрузка игрового сценария...                      |");
	printf("|-----------------------------------------------------------------------------|");
}


public OnGameModeInit()
{
	// Don't use these lines if it's a filterscript
	pl = mysql_connect(sqlhost,sqluser,sqldb,sqlpass);
	mysql_function_query(pl,"SELECT * FROM `houses`", true, "HouseLoad", "");
	mysql_function_query(pl,"SELECT * FROM `cars`", true, "CarsLoad", "");
	if(mysql_ping(pl) < 1) print("MySQL not found"); else print("MySQL found");
	SetGameModeText("«BIG BAZEW MOd»");
	new temp[65];
	format(temp,sizeof(temp),"lolka");
	print(temp);
	SHA256_PassHash(temp, salt, temp, 65);
	print(temp);
	DisableInteriorEnterExits();
	AddPlayerClass(0, 1958.3783, 1343.1572, 15.3746, 269.1425, 0, 0, 0, 0, 0, 0);
 	CreateObject(3749, 1556.28516, -1801.81238, 18.35762,   0.00000, 0.00000, 90.00000, 50000.0);
  	CreateObject(3749, 1556.07764, -1778.85852, 18.22350,   0.00000, 0.00000, 90.00000, 50000.0);
   	CreateObject(983, 1558.09534, -1790.23291, 13.27360,   0.00000, 0.00000, 0.00000, 50000.0);
    CreateObject(10377, 1482.89722, -1783.55896, 30.64250,   0.00000, 0.00000, 91.00000, 50000.0);
    CreateObject(4003, 1509.88342, -1771.83337, 33.41935,   0.00000, 0.00000, 0.00000, 50000.0);
    CreateObject(4003, 1482.02820, -1764.07275, 34.31907,   0.00000, 0.00000, 0.00000, 50000.0);
    CreateObject(4003, 1451.34839, -1772.98181, 33.05471,   0.00000, 0.00000, 0.00000, 50000.0);
    CreateObject(984, 1497.92249, -1756.53369, 13.22627,   0.00000, 0.00000, 0.00000, 50000.0);
    CreateObject(984, 1491.52393, -1750.01196, 13.19390,   0.00000, 0.00000, 90.00000, 50000.0);
    CreateObject(984, 1473.79919, -1750.26331, 13.20367,   0.00000, 0.00000, 91.00000, 50000.0);
    CreateObject(984, 1467.39490, -1756.74976, 13.25575,   0.00000, 0.00000, 0.00000, 50000.0);
    CreateObject(983, 1480.24304, -1746.87878, 13.28900,   0.00000, 0.00000, 0.00000, 50000.0);
    CreateObject(983, 1485.14978, -1746.63647, 13.44740,   0.00000, 0.00000, 0.00000, 50000.0);
    CreateObject(19425, 1487.05066, -1734.91907, 12.37190,   0.00000, 0.00000, -91.00000, 50000.0);
    CreateObject(19425, 1496.28882, -1729.65771, 12.37110,   0.00000, 0.00000, 90.00000, 50000.0);
    CreateObject(19425, 1477.78870, -1729.57068, 12.37160,   0.00000, 0.00000, 92.00000, 50000.0);
    CreateObject(19425, 1466.34167, -1735.11340, 12.36990,   0.00000, 0.00000, 91.00000, 50000.0);
    CreateObject(19425, 1456.75500, -1729.87317, 12.37070,   0.00000, 0.00000, 91.00000, 50000.0);
    CreateObject(19425, 1447.02112, -1734.77991, 12.36960,   0.00000, 0.00000, 90.00000, 50000.0);
    CreateObject(19425, 1509.46704, -1734.64612, 12.36670,   0.00000, 0.00000, 89.00000, 50000.0);
    CreateObject(19425, 1519.72534, -1729.84827, 12.36580,   0.00000, 0.00000, 91.00000, 50000.0);
    CreateObject(982, 1510.32178, -1732.26501, 13.09227,   0.00000, 0.00000, 90.00000, 50000.0);
    CreateObject(982, 1484.68994, -1732.30383, 13.07802,   0.00000, 0.00000, 90.00000, 50000.0);
    CreateObject(982, 1459.03467, -1732.31323, 13.07971,   0.00000, 0.00000, 90.00000, 50000.0);
    CreateObject(621, 1515.06726, -1724.63611, 12.53726,   0.00000, 0.00000, 0.00000, 50000.0);
    CreateObject(621, 1501.82629, -1724.46863, 12.52913,   0.00000, 0.00000, 0.00000, 50000.0);
    CreateObject(621, 1489.29944, -1725.09863, 12.53793,   0.00000, 0.00000, 0.00000, 50000.0);
    CreateObject(621, 1475.30627, -1724.26587, 12.53260,   0.00000, 0.00000, 0.00000, 50000.0);
    CreateObject(621, 1463.39307, -1724.29358, 12.53677,   0.00000, 0.00000, 0.00000, 50000.0);
    CreateObject(621, 1451.70789, -1723.57898, 12.53692,   0.00000, 0.00000, 0.00000, 50000.0);
    CreateObject(621, 1442.57727, -1723.69727, 12.53436,   0.00000, 0.00000, 0.00000, 50000.0);
    CreateObject(621, 1441.97424, -1740.50635, 12.53552,   0.00000, 0.00000, 0.00000, 50000.0);
    CreateObject(621, 1451.96130, -1740.33252, 12.53972,   0.00000, 0.00000, 0.00000, 50000.0);
    CreateObject(621, 1463.85291, -1740.07996, 12.54551,   0.00000, 0.00000, 0.00000, 50000.0);
    CreateObject(621, 1475.34399, -1740.19641, 12.54551,   0.00000, 0.00000, 0.00000, 50000.0);
    CreateObject(621, 1489.74976, -1740.40454, 12.54148,   0.00000, 0.00000, 0.00000, 50000.0);
    CreateObject(621, 1502.30286, -1740.19360, 12.39136,   0.00000, 0.00000, 0.00000, 50000.0);
    CreateObject(621, 1515.66003, -1739.66553, 12.54282,   0.00000, 0.00000, 0.00000, 50000.0);
    CreateObject(982, 1461.77319, -1737.69043, 13.23403,   0.00000, 0.00000, 90.00000, 50000.0);
    CreateObject(982, 1487.42896, -1737.70093, 13.21489,   0.00000, 0.00000, 90.00000, 50000.0);
    CreateObject(982, 1513.02173, -1737.68176, 13.26596,   0.00000, 0.00000, 90.00000, 50000.0);
    CreateObject(982, 1460.44580, -1726.40405, 13.22941,   0.00000, 0.00000, 89.00000, 50000.0);
    CreateObject(982, 1486.05444, -1726.86096, 13.24789,   0.00000, 0.00000, 89.00000, 50000.0);
    CreateObject(982, 1511.66150, -1727.09851, 13.26962,   0.00000, 0.00000, 90.00000, 50000.0);
    CreateObject(3472, 1521.37073, -1724.45129, 12.54450,   0.00000, 0.00000, 0.00000, 50000.0);
    CreateObject(3472, 1521.62708, -1739.21765, 12.53564,   0.00000, 0.00000, 0.00000, 50000.0);
    CreateObject(3472, 1508.34619, -1724.73376, 12.54247,   0.00000, 0.00000, 0.00000, 50000.0);
    CreateObject(3472, 1508.17871, -1740.56201, 12.54665,   0.00000, 0.00000, 0.00000, 50000.0);
    CreateObject(3472, 1496.03174, -1740.23096, 12.54150,   0.00000, 0.00000, 0.00000, 50000.0);
    CreateObject(3472, 1496.37012, -1723.98059, 12.54665,   0.00000, 0.00000, 0.00000, 50000.0);
    CreateObject(3472, 1482.68481, -1723.69519, 12.54542,   0.00000, 0.00000, 0.00000, 50000.0);
    CreateObject(3472, 1483.19678, -1740.10107, 12.54521,   0.00000, 0.00000, 0.00000, 50000.0);
    CreateObject(3472, 1469.48938, -1739.84631, 12.54545,   0.00000, 0.00000, 0.00000, 50000.0);
    CreateObject(3472, 1469.04785, -1724.68628, 12.54646,   0.00000, 0.00000, 0.00000, 50000.0);
    CreateObject(3472, 1458.20593, -1739.88977, 12.53851,   0.00000, 0.00000, 0.00000, 50000.0);
    CreateObject(3472, 1456.01050, -1723.54224, 12.54245,   0.00000, 0.00000, 0.00000, 50000.0);
    CreateObject(3472, 1446.26782, -1740.10144, 12.53292,   0.00000, 0.00000, 0.00000, 50000.0);
    CreateObject(3472, 1447.52576, -1724.00403, 12.53681,   0.00000, 0.00000, 0.00000, 50000.0);
    CreateObject(640, -8470.86523, 664.53809, 91.63754,   0.00000, 0.00000, 0.00000, 50000.0);
    CreateObject(640, 1495.10364, -1749.40955, 13.20860,   0.00000, 0.00000, 90.00000, 50000.0);
    CreateObject(640, 1470.36865, -1749.44568, 13.23833,   0.00000, 0.00000, 91.00000, 50000.0);
    CreateObject(1256, 1486.88586, -1749.06409, 13.11050,   0.00000, 0.00000, 269.00000, 50000.0);
    CreateObject(1256, 1490.34802, -1749.03638, 13.23150,   0.00000, 0.00000, 269.00000, 50000.0);
    CreateObject(1256, 1474.89551, -1749.45581, 13.22929,   0.00000, 0.00000, 271.00000, 50000.0);
    CreateObject(1256, 1478.13220, -1749.39319, 13.16760,   0.00000, 0.00000, 271.00000, 50000.0);
    CreateObject(1594, 1494.70129, -1752.27344, 12.54209,   0.00000, 0.00000, 0.00000, 50000.0);
    CreateObject(1594, 1494.88867, -1755.64526, 12.54476,   0.00000, 0.00000, 0.00000, 50000.0);
    CreateObject(1594, 1471.03162, -1756.54626, 12.54358,   0.00000, 0.00000, 0.00000, 50000.0);
    CreateObject(1594, 1471.14294, -1752.72998, 12.54346,   0.00000, 0.00000, 0.00000, 50000.0);
    CreateObject(1570, 1489.25037, -1751.68347, 13.83140,   0.00000, 0.00000, 179.00000, 50000.0);
    CreateObject(1570, 1475.77515, -1751.36206, 13.80204,   0.00000, 0.00000, 183.00000, 50000.0);
    CreateObject(3749, 1403.52332, -1778.80066, 18.33840,   0.00000, 0.00000, 90.00000, 50000.0);
    CreateObject(3749, 1403.29443, -1801.40808, 18.29583,   0.00000, 0.00000, 269.00000, 50000.0);
    CreateObject(983, 1401.53162, -1789.97083, 13.37359,   0.00000, 0.00000, 0.00000, 50000.0);
    CreateObject(10183, 1429.97009, -1756.38977, 12.53810,   0.00000, 0.00000, 45.00000, 50000.0);
    CreateObject(10183, 1528.61194, -1756.45728, 12.54070,   0.00000, 0.00000, 45.50000, 50000.0);



	CreateVehicle(402, 1511.3699, -1756.1324, 13.2165, 0.0000, -1, -1, 100);
 	CreateVehicle(409, 1516.4052, -1757.3755, 13.1989, 0.0000, -1, -1, 100);
  	CreateVehicle(411, 1526.2623, -1756.3876, 13.1135, 0.0000, -1, -1, 100);
   	CreateVehicle(420, 1540.8597, -1756.1082, 13.1813, 0.0000, -1, -1, 100);
   	CreateVehicle(424, 1412.5078, -1755.5658, 13.2648, 0.0000, -1, -1, 100);
    CreateVehicle(429, 1422.3329, -1756.2405, 13.1499, 0.0000, -1, -1, 100);
    CreateVehicle(439, 1431.9733, -1756.7715, 13.2742, 0.0000, -1, -1, 100);

	

	new tmpobjid;
	tmpobjid = CreateObject(19378,2483.471,-867.949,2882.313,0.000,90.000,0.000,300.000);
	SetObjectMaterial(tmpobjid, 0, 2755, "ab_dojowall", "mp_apt1_roomfloor", 0);
	tmpobjid = CreateObject(19378,2493.966,-867.949,2882.313,0.000,90.000,0.000,300.000);
	SetObjectMaterial(tmpobjid, 0, 2755, "ab_dojowall", "mp_apt1_roomfloor", 0);
	tmpobjid = CreateObject(19387,2483.029,-872.630,2884.149,0.000,0.000,90.000,300.000);
	SetObjectMaterial(tmpobjid, 0, 3603, "bevmans01_la", "hottop5d_law", 0);
	SetObjectMaterial(tmpobjid, 2, 14581, "ab_mafiasuitea", "mp_burn_ceiling", 0);
	tmpobjid = CreateObject(19357,2479.823,-872.630,2884.149,0.000,0.000,90.000,300.000);
	SetObjectMaterial(tmpobjid, 0, 3603, "bevmans01_la", "hottop5d_law", 0);
	tmpobjid = CreateObject(19357,2486.210,-872.630,2884.149,0.000,0.000,90.000,300.000);
	SetObjectMaterial(tmpobjid, 0, 3603, "bevmans01_la", "hottop5d_law", 0);
	SetObjectMaterial(tmpobjid, 2, 14581, "ab_mafiasuitea", "mp_burn_ceiling", 0);
	tmpobjid = CreateObject(19357,2489.416,-872.630,2884.149,0.000,0.000,90.000,300.000);
	SetObjectMaterial(tmpobjid, 0, 3603, "bevmans01_la", "hottop5d_law", 0);
	tmpobjid = CreateObject(19449,2478.272,-867.857,2884.149,0.000,0.000,0.000,300.000);
	SetObjectMaterial(tmpobjid, 0, 3603, "bevmans01_la", "hottop5d_law", 0);
	tmpobjid = CreateObject(19449,2483.018,-868.284,2884.149,0.000,0.000,90.000,300.000);
	SetObjectMaterial(tmpobjid, 0, 3603, "bevmans01_la", "hottop5d_law", 0);
	tmpobjid = CreateObject(1429,2482.362,-868.741,2883.456,0.000,0.000,315.000,300.000);
	SetObjectMaterial(tmpobjid, 0, 14581, "ab_mafiasuitea", "cof_wood2", 0);
	SetObjectMaterial(tmpobjid, 1, 14803, "bdupsnew", "Bdup2_poster", 0);
	SetObjectMaterial(tmpobjid, 2, 14581, "ab_mafiasuitea", "cof_wood2", 0);
	tmpobjid = CreateObject(936,2484.566,-871.661,2882.875,0.000,0.000,90.000,300.000);
	SetObjectMaterial(tmpobjid, 1, 2023, "bitsnbobs", "CJ_LIGHTWOOD", 0);
	tmpobjid = CreateObject(1796,2484.016,-868.870,2882.399,0.000,0.000,270.000,300.000);
	SetObjectMaterial(tmpobjid, 1, 9515, "bigboxtemp1", "board64_law", 0);
	SetObjectMaterial(tmpobjid, 2, 9583, "bigshap_sfw", "bridge_walls2_sfw", 0);
	tmpobjid = CreateObject(19357,2489.371,-868.284,2884.149,0.000,0.000,90.000,300.000);
	SetObjectMaterial(tmpobjid, 0, 3603, "bevmans01_la", "hottop5d_law", 0);
	tmpobjid = CreateObject(19387,2487.961,-871.015,2884.149,0.000,0.000,0.000,300.000);
	SetObjectMaterial(tmpobjid, 0, 3603, "bevmans01_la", "hottop5d_law", 0);
	tmpobjid = CreateObject(19357,2487.961,-867.809,2884.149,0.000,0.000,0.000,300.000);
	SetObjectMaterial(tmpobjid, 0, 3603, "bevmans01_la", "hottop5d_law", 0);
	tmpobjid = CreateObject(2267,2486.178,-868.401,2884.394,0.000,0.000,0.000,300.000);
	SetObjectMaterial(tmpobjid, 1, 14489, "carlspics", "AH_landscap1", 0);
	tmpobjid = CreateObject(2266,2478.852,-870.510,2883.994,0.000,0.000,90.000,300.000);
	SetObjectMaterial(tmpobjid, 1, 14489, "carlspics", "AH_picture2", 0);
	tmpobjid = CreateObject(1498,2482.249,-872.616,2882.389,0.000,0.000,0.000,300.000);
	SetObjectMaterial(tmpobjid, 1, 14489, "carlspics", "AH_landscap1", 0);
	tmpobjid = CreateObject(19449,2490.855,-867.859,2884.149,0.000,0.000,0.000,300.000);
	SetObjectMaterial(tmpobjid, 0, 3603, "bevmans01_la", "hottop5d_law", 0);
	tmpobjid = CreateObject(19379,2483.471,-867.949,2885.989,0.000,90.000,0.000,300.000);
	SetObjectMaterial(tmpobjid, 0, 6282, "beafron2_law2", "boardwalk2_la", 0);
	tmpobjid = CreateObject(19379,2493.966,-867.949,2885.989,0.000,90.000,0.000,300.000);
	SetObjectMaterial(tmpobjid, 0, 6282, "beafron2_law2", "boardwalk2_la", 0);
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	CreateObject(19357,2492.624,-872.630,2884.149,0.000,0.000,90.000,300.000);
	CreateObject(1764,2478.782,-871.443,2882.399,0.000,0.000,90.000,300.000);
	CreateObject(936,2485.895,-872.145,2882.874,0.000,0.000,180.000,300.000);
 	CreateObject(1744,2482.279,-868.370,2884.281,0.000,0.000,0.000,300.000);
	CreateObject(1765,2479.804,-868.781,2882.399,0.000,0.000,0.000,300.000);
	CreateObject(1765,2480.892,-872.124,2882.399,0.000,0.000,180.000,300.000);
	CreateObject(1819,2479.912,-870.947,2882.399,0.000,0.000,0.000,300.000);
	CreateObject(2141,2487.344,-872.057,2882.399,0.000,0.000,180.000,300.000);
	CreateObject(2328,2482.430,-869.859,2882.399,0.000,0.000,0.000,300.000);
	CreateObject(2866,2486.052,-872.015,2883.350,0.000,0.000,0.000,300.000);
	CreateObject(2859,2480.482,-870.484,2882.916,0.000,0.000,0.000,300.000);
	CreateObject(2845,2482.882,-869.500,2882.399,0.000,0.000,0.000,300.000);
	CreateObject(2384,2483.260,-868.635,2884.726,0.000,0.000,0.000,300.000);
	CreateObject(2806,2484.568,-871.653,2883.469,0.000,0.000,0.000,300.000);
	CreateObject(2103,2482.377,-868.668,2884.623,0.000,0.000,0.000,300.000);
	CreateObject(2149,2485.327,-872.333,2883.500,0.000,0.000,180.000,300.000);
	CreateObject(2225,2481.905,-868.896,2882.399,0.000,0.000,270.000,300.000);
	CreateObject(630,2479.093,-868.882,2883.425,0.000,0.000,0.000,300.000);
	CreateObject(630,2479.062,-872.059,2883.425,0.000,0.000,0.000,300.000);
	CreateObject(2527,2490.177,-869.851,2882.399,0.000,0.000,0.000,300.000);
	CreateObject(2525,2489.458,-872.057,2882.399,0.000,0.000,180.000,300.000);
	CreateObject(2524,2490.271,-870.672,2882.399,0.000,0.000,270.000,300.000);
	CreateObject(1846,2489.774,-871.088,2884.299,90.000,90.000,0.000,300.000);
	CreateObject(2074,2483.460,-870.151,2885.628,0.000,0.000,0.000,300.000);
	CreateObject(1494,2487.952,-871.763,2882.399,0.000,0.000,90.000,300.000);
	
	CreateObject(17522,1956.1064453,-289.0268860,4841.9780273,0.0000000,0.0000000,0.0000000); //object(gangshop7_lae2) (1)
	CreateObject(19454,1957.6656494,-291.2015991,4845.4570312,0.0000000,90.0000000,0.0000000); //object(wall094) (1)
	CreateObject(19447,1961.1610107,-291.1990967,4845.4570312,0.0000000,90.0000000,0.0000000); //object(wall087) (1)
	CreateObject(19354,1955.9996338,-294.4028015,4847.2929688,0.0000000,0.0000000,0.0000000); //object(wall002) (1)
	CreateObject(19354,1955.9987793,-291.1961975,4847.2929688,0.0000000,0.0000000,0.0000000); //object(wall002) (2)
	CreateObject(19384,1955.9991455,-287.9845886,4847.2929688,0.0000000,0.0000000,0.0000000); //object(wall032) (1)
	CreateObject(19454,1954.1697998,-291.2047119,4845.4570312,0.0000000,90.0000000,0.0000000); //object(wall094) (3)
	CreateObject(19454,1950.6689453,-291.2078857,4845.4570312,0.0000000,90.0000000,0.0000000); //object(wall094) (4)
	CreateObject(19454,1954.1910400,-281.6133118,4845.4570312,0.0000000,90.0000000,0.0000000); //object(wall094) (5)
	CreateObject(19454,1950.6899414,-281.5704956,4845.4570312,0.0000000,90.0000000,0.0000000); //object(wall094) (6)
	CreateObject(1745,1952.4100342,-292.1231079,4845.5429688,0.0000000,0.0000000,270.0000000); //object(med_bed_3) (1)
	CreateObject(1778,1962.5395508,-285.7976074,4845.5390625,0.0000000,0.0000000,30.0000000); //object(cj_mop_pail) (1)
	CreateObject(1828,1954.5473633,-287.8338928,4845.5429688,0.0000000,0.0000000,90.1874695); //object(man_sdr_rug) (1)
	CreateObject(2103,1953.1143799,-285.3283997,4845.5429688,0.0000000,0.0000000,0.0000000); //object(low_hi_fi_1) (1)
	CreateObject(2149,1956.5743408,-284.9773865,4846.7485352,0.0000000,0.0000000,90.0000000); //object(cj_microwave1) (1)
	CreateObject(2296,1949.3803711,-293.6676025,4845.5429688,0.0000000,0.0000000,90.0000000); //object(tv_unit_1) (1)
	CreateObject(19354,1948.9974365,-294.4179993,4847.2929688,0.0000000,0.0000000,0.0000000); //object(wall002) (4)
	CreateObject(19354,1948.9969482,-291.2085876,4847.2929688,0.0000000,0.0000000,0.0000000); //object(wall002) (5)
	CreateObject(19354,1954.3596191,-284.7109070,4847.2929688,0.0000000,0.0000000,270.0000000); //object(wall002) (6)
	CreateObject(19354,1948.9970703,-287.9960938,4847.2929688,0.0000000,0.0000000,0.0000000); //object(wall002) (7)
	CreateObject(19354,1950.6914062,-295.9328918,4847.2929688,0.0000000,0.0000000,90.0000000); //object(wall002) (8)
	CreateObject(19354,1953.9035645,-295.9360046,4847.2929688,0.0000000,0.0000000,90.0000000); //object(wall002) (9)
	CreateObject(19354,1954.4864502,-295.9306946,4847.2929688,0.0000000,0.0000000,90.0000000); //object(wall002) (10)
	CreateObject(2332,1953.0843506,-295.4060974,4846.0058594,0.0000000,0.0000000,180.0000000); //object(kev_safe) (1)
	CreateObject(2339,1962.3144531,-283.6047974,4845.5390625,0.0000000,0.0000000,270.0000000); //object(cj_kitch2_cooker) (1)
	CreateObject(2344,1949.6595459,-291.4689026,4846.0375977,0.0000000,0.0000000,0.0000000); //object(cj_remote) (1)
	CreateObject(2522,1960.5018311,-287.2958069,4845.5429688,0.0000000,0.0000000,270.0000000); //object(cj_bath3) (1)
	CreateObject(2523,1961.7669678,-292.4719849,4845.5429688,0.0000000,0.0000000,180.0000000); //object(cj_b_sink3) (1)
	CreateObject(2525,1962.3731689,-287.2572021,4845.5429688,0.0000000,0.0000000,0.0000000); //object(cj_toilet4) (1)
	CreateObject(2827,1953.0589600,-295.5223083,4846.4775391,0.0000000,0.0000000,0.0000000); //object(gb_novels05) (1)
	CreateObject(19354,1955.9978027,-284.7983093,4847.2924805,0.0000000,0.0000000,0.0000000); //object(wall002) (11)
	CreateObject(19354,1951.1523438,-284.7095947,4847.2929688,0.0000000,0.0000000,270.0000000); //object(wall002) (12)
	CreateObject(19354,1949.0015869,-284.7875061,4847.2929688,0.0000000,0.0000000,0.0000000); //object(wall002) (13)
	CreateObject(19354,1947.9420166,-284.7127991,4847.2929688,0.0000000,0.0000000,270.0000000); //object(wall002) (14)
	CreateObject(19381,1951.0964355,-290.5964050,4848.9516602,0.0000000,90.0000000,270.0000000); //object(wall029) (1)
	CreateObject(19381,1951.0882568,-280.0965881,4848.9516602,0.0000000,90.0000000,270.0000000); //object(wall029) (2)
	CreateObject(1491,1956.0135498,-288.7301025,4845.5371094,0.0000000,0.0000000,90.0000000); //object(gen_doorint01) (1)
	CreateObject(3963,1951.6800537,-295.8406067,4847.7841797,0.0000000,0.0000000,358.9367676); //object(lee_plane08) (1)
	CreateObject(2290,1949.5871582,-285.2940063,4845.5429688,0.0000000,0.0000000,0.0000000); //object(swk_couch_1) (1)
	CreateObject(2289,1952.1894531,-284.8367920,4847.8666992,0.0000000,0.0000000,0.0000000); //object(frame_2) (1)
	CreateObject(2286,1955.8981934,-292.6102905,4847.7661133,0.0000000,0.0000000,270.0000000); //object(frame_5) (1)
	CreateObject(2284,1949.5632324,-289.4389954,4847.6186523,0.0000000,0.0000000,90.0000000); //object(frame_6) (1)
	CreateObject(2118,1950.0633545,-287.1875916,4845.5429688,0.0000000,0.0000000,0.0000000); //object(swank_dinning_6) (1)
	CreateObject(2117,1949.6093750,-290.0750122,4845.5429688,0.0000000,0.0000000,90.0000000); //object(swank_dinning_5) (1)
	CreateObject(2114,1955.4743652,-295.4461975,4845.6894531,0.0000000,0.0000000,0.0000000); //object(basketball) (1)
	CreateObject(2023,1949.6744385,-295.0252991,4845.5429688,0.0000000,0.0000000,0.0000000); //object(mrk_stnd_lmp) (1)
	CreateObject(1766,1956.5893555,-291.6961060,4845.5429688,0.0000000,0.0000000,90.0000000); //object(med_couch_1) (1)
	CreateObject(1758,1954.8061523,-285.3728943,4845.5429688,0.0000000,0.0000000,319.9620361); //object(low_single_4) (1)
	CreateObject(2356,1950.9389648,-289.4919128,4845.5429688,0.0000000,0.0000000,90.0000000); //object(police_off_chair) (1)
	CreateObject(2605,1951.3320312,-295.4079895,4845.9414062,0.0000000,0.0000000,180.0000000); //object(polce_desk1) (1)
	CreateObject(1663,1951.2086182,-294.3501892,4846.0034180,0.0000000,0.0000000,0.0000000); //object(swivelchair_b) (1)
	CreateObject(2843,1953.5250244,-295.8642883,4845.5429688,0.0000000,0.0000000,0.0000000); //object(gb_bedclothes02) (1)
	CreateObject(2845,1954.4842529,-295.8807983,4845.5429688,0.0000000,0.0000000,10.0000000); //object(gb_bedclothes04) (1)
	CreateObject(19384,1957.6936035,-286.4729004,4847.2929688,0.0000000,0.0000000,270.0000000); //object(wall032) (2)
	CreateObject(19455,1956.0501709,-281.5972900,4847.2978516,0.0000000,0.0000000,0.0000000); //object(wall095) (1)
	CreateObject(19392,1957.7337646,-286.4703979,4847.2954102,0.0000000,0.0000000,90.0000000); //object(wall040) (1)
	CreateObject(19354,1960.9006348,-286.4732971,4847.2929688,0.0000000,0.0000000,270.0000000); //object(wall002) (15)
	CreateObject(19452,1957.6804199,-281.5726013,4845.4531250,0.0000000,90.0000000,0.0000000); //object(wall092) (1)
	CreateObject(1523,1956.9416504,-286.5212097,4845.5278320,0.0000000,0.0000000,0.0000000); //object(gen_doorext10) (1)
	CreateObject(19452,1961.1789551,-281.5656128,4845.4531250,0.0000000,90.0000000,0.0000000); //object(wall092) (2)
	CreateObject(19363,1960.9422607,-286.4700012,4847.2929688,0.0000000,0.0000000,90.0000000); //object(wall011) (1)
	CreateObject(19354,1959.9366455,-288.1665955,4847.2929688,0.0000000,0.0000000,180.0000000); //object(wall002) (16)
	CreateObject(2158,1956.6463623,-281.9050903,4845.5390625,0.0000000,0.0000000,90.0000000); //object(cj_kitch1_l) (1)
	CreateObject(2159,1962.6318359,-281.6431885,4845.5566406,0.0000000,0.0000000,270.0000000); //object(cj_k6_low_unit4) (1)
	CreateObject(2160,1957.4659424,-280.4143982,4845.5390625,0.0000000,0.0000000,0.0000000); //object(cj_k6_low_unit3) (1)
	CreateObject(2337,1958.8352051,-280.7302856,4845.5390625,0.0000000,0.0000000,0.0000000); //object(cj_kitch1_washer) (1)
	CreateObject(2340,1960.0952148,-280.7012024,4845.5390625,0.0000000,0.0000000,0.0000000); //object(cj_kitch2_washer) (2)
	CreateObject(2131,1960.4931641,-285.8706055,4845.5390625,0.0000000,0.0000000,180.0000000); //object(cj_kitch2_fridge) (1)
	CreateObject(2335,1956.6575928,-284.9717102,4845.5390625,0.0000000,0.0000000,90.0000000); //object(cj_kitch1_r) (1)
	CreateObject(2338,1962.3409424,-280.6625977,4845.5390625,0.0000000,0.0000000,0.0000000); //object(cj_kitch1_corner) (1)
	CreateObject(2335,1961.3320312,-280.6835938,4845.5390625,0.0000000,0.0000000,0.0000000); //object(cj_kitch1_r) (2)
	CreateObject(2335,1956.6572266,-282.9746094,4845.5390625,0.0000000,0.0000000,90.0000000); //object(cj_kitch1_r) (3)
	CreateObject(2335,1956.6591797,-283.9746094,4845.5390625,0.0000000,0.0000000,90.0000000); //object(cj_kitch1_r) (4)
	CreateObject(1432,1959.4395752,-283.1596985,4845.5390625,0.0000000,0.0000000,0.0000000); //object(dyn_table_2) (1)
	CreateObject(2700,1956.4150391,-283.3732910,4848.3950195,0.0000000,0.0000000,0.0000000); //object(cj_sex_tv2) (1)
	CreateObject(2847,1957.4245605,-295.8966064,4845.5429688,0.0000000,0.0000000,0.0000000); //object(gb_bedrug05) (1)
	CreateObject(19455,1960.9542236,-280.1104126,4847.2978516,0.0000000,0.0000000,270.0000000); //object(wall095) (2)
	CreateObject(19455,1962.9307861,-281.6733093,4847.2978516,0.0000000,0.0000000,180.0000000); //object(wall095) (3)
	CreateObject(19363,1964.1197510,-286.4692993,4847.2929688,0.0000000,0.0000000,90.0000000); //object(wall011) (2)
	CreateObject(1510,1962.5445557,-284.7325134,4845.5522461,0.0000000,0.0000000,0.0000000); //object(dyn_ashtry) (1)
	CreateObject(1510,1962.5357666,-285.2453003,4845.5522461,0.0000000,0.0000000,0.0000000); //object(dyn_ashtry) (2)
	CreateObject(2776,1961.4520264,-286.0698853,4846.0366211,0.0000000,0.0000000,180.0000000); //object(lee_stripchair2) (1)
	CreateObject(19380,1961.3856201,-281.5690918,4848.9599609,0.0000000,90.0000000,0.0000000); //object(wall028) (1)
	CreateObject(19353,1959.9377441,-288.1661072,4847.2929688,0.0000000,0.0000000,0.0000000); //object(wall001) (1)
	CreateObject(19383,1959.9377441,-291.3758850,4847.2915039,0.0000000,0.0000000,0.0000000); //object(wall031) (1)
	CreateObject(19384,1959.9317627,-291.3756104,4847.2929688,0.0000000,0.0000000,0.0000000); //object(wall032) (3)
	CreateObject(1492,1959.9156494,-290.5928040,4845.5346680,0.0000000,0.0000000,270.0000000); //object(gen_doorint02) (1)
	CreateObject(19354,1959.9322510,-294.5848083,4847.2929688,0.0000000,0.0000000,179.9945068); //object(wall002) (17)
	CreateObject(19354,1958.2414551,-296.0516052,4847.2929688,0.0000000,0.0000000,89.9945068); //object(wall002) (18)
	CreateObject(19354,1955.0345459,-296.0498962,4847.2929688,0.0000000,0.0000000,89.9945068); //object(wall002) (19)
	CreateObject(1535,1957.1394043,-296.0324097,4845.5327148,0.0000000,0.0000000,0.0000000); //object(gen_doorext14) (1)
	CreateObject(2263,1959.1617432,-287.0585938,4847.3916016,0.0000000,0.0000000,0.0000000); //object(frame_slim_4) (1)
	CreateObject(2262,1956.5798340,-290.3417053,4847.2983398,0.0000000,0.0000000,90.0000000); //object(frame_slim_3) (1)
	CreateObject(2260,1956.5661621,-293.0516968,4847.2651367,0.0000000,0.0000000,90.0000000); //object(frame_slim_1) (1)
	CreateObject(2259,1959.3802490,-288.9884033,4846.8544922,0.0000000,0.0000000,270.0000000); //object(frame_clip_6) (1)
	CreateObject(2258,1959.8320312,-293.8504028,4847.4882812,0.0000000,0.0000000,270.0000000); //object(frame_clip_5) (1)
	CreateObject(631,1959.3559570,-295.7203979,4846.4433594,0.0000000,0.0000000,300.0000000); //object(veg_palmkb9) (1)
	CreateObject(631,1956.4104004,-295.5256042,4846.4433594,0.0000000,0.0000000,219.9981689); //object(veg_palmkb9) (2)
	CreateObject(19353,1961.6363525,-286.6585999,4847.2929688,0.0000000,0.0000000,270.0000000); //object(wall001) (2)
	CreateObject(19353,1962.9991455,-288.3486938,4847.2929688,0.0000000,0.0000000,180.0000000); //object(wall001) (3)
	CreateObject(19353,1962.9980469,-291.5574951,4847.2929688,0.0000000,0.0000000,179.9945068); //object(wall001) (4)
	CreateObject(19353,1961.6234131,-293.0744934,4847.2929688,0.0000000,0.0000000,89.9945068); //object(wall001) (5)
	CreateObject(19454,1958.1062012,-291.1889954,4845.4584961,0.0000000,90.0000000,0.0000000); //object(wall094) (2)
	CreateObject(2815,1962.0002441,-288.4880981,4845.5429688,0.0000000,0.0000000,90.0000000); //object(gb_livingrug01) (1)
	CreateObject(2846,1961.7181396,-292.7843933,4845.5429688,0.0000000,0.0000000,0.0000000); //object(gb_bedclothes05) (1)
	CreateObject(2844,1960.0545654,-290.1651917,4845.5429688,0.0000000,0.0000000,0.0000000); //object(gb_bedclothes03) (1)
	CreateObject(19458,1961.7550049,-291.3450928,4848.9560547,0.0000000,90.0000000,0.0000000); //object(wall098) (2)
	CreateObject(19454,1957.8376465,-291.3750916,4848.9511719,0.0000000,90.0000000,0.0000000); //object(wall094) (8)
	CreateObject(19454,1958.1053467,-291.3760071,4848.9541016,0.0000000,90.0000000,0.0000000); //object(wall094) (9)
	
	new bcshop;
	bcshop = CreateDynamicObject(19462,-2943.169,2570.260,118.000,0.000,90.000,0.000,-1,-1,-1);
	SetDynamicObjectMaterial(bcshop, 0, 14777, "int_casinoint3", "GB_midbar05", 0);
	bcshop = CreateDynamicObject(19462,-2946.659,2570.280,118.000,0.000,90.000,0.000,-1,-1,-1);
	SetDynamicObjectMaterial(bcshop, 0, 14777, "int_casinoint3", "GB_midbar05", 0);
	bcshop = CreateDynamicObject(19462,-2950.149,2570.300,118.000,0.000,90.000,0.000,-1,-1,-1,300.000);
	SetDynamicObjectMaterial(bcshop, 0, 14777, "int_casinoint3", "GB_midbar05", 0);
	bcshop = CreateDynamicObject(19462,-2953.659,2570.270,118.000,0.000,90.000,0.000,-1,-1,-1,300.000);
	SetDynamicObjectMaterial(bcshop, 0, 14777, "int_casinoint3", "GB_midbar05", 0);
	bcshop = CreateDynamicObject(19462,-2943.179,2579.899,118.000,0.000,90.000,0.000,-1,-1,-1,300.000);
	SetDynamicObjectMaterial(bcshop, 0, 14777, "int_casinoint3", "GB_midbar05", 0);
	bcshop = CreateDynamicObject(19462,-2946.669,2579.870,118.000,0.000,90.000,0.000,-1,-1,-1,300.000);
	SetDynamicObjectMaterial(bcshop, 0, 14777, "int_casinoint3", "GB_midbar05", 0);
	bcshop = CreateDynamicObject(19462,-2950.129,2579.919,118.000,0.000,90.000,0.000,-1,-1,-1,300.000);
	SetDynamicObjectMaterial(bcshop, 0, 14777, "int_casinoint3", "GB_midbar05", 0);
	bcshop = CreateDynamicObject(19462,-2953.639,2579.899,117.980,0.000,90.000,0.000,-1,-1,-1,300.000);
	SetDynamicObjectMaterial(bcshop, 0, 14777, "int_casinoint3", "GB_midbar05", 0);
	bcshop = CreateDynamicObject(19462,-2957.100,2579.909,118.000,0.000,90.000,0.000,-1,-1,-1,300.000);
	SetDynamicObjectMaterial(bcshop, 0, 14777, "int_casinoint3", "GB_midbar05", 0);
	bcshop = CreateDynamicObject(19462,-2957.100,2570.280,118.000,0.000,90.000,0.000,-1,-1,-1,300.000);
	SetDynamicObjectMaterial(bcshop, 0, 14777, "int_casinoint3", "GB_midbar05", 0);
	bcshop = CreateDynamicObject(19446,-2941.610,2570.199,119.800,0.000,0.000,359.239,-1,-1,-1,300.000);
	SetDynamicObjectMaterial(bcshop, 0, 14415, "carter_block_2", "mp_motel_carpet1", 0);
	bcshop = CreateDynamicObject(19446,-2941.600,2579.820,119.800,0.000,0.000,0.709,-1,-1,-1,300.000);
	SetDynamicObjectMaterial(bcshop, 0, 14415, "carter_block_2", "mp_motel_carpet1", 0);
	bcshop = CreateDynamicObject(19446,-2946.250,2584.580,119.800,0.000,0.000,90.480,-1,-1,-1,300.000);
	SetDynamicObjectMaterial(bcshop, 0, 14415, "carter_block_2", "mp_motel_carpet1", 0);
	bcshop = CreateDynamicObject(19446,-2958.790,2570.830,119.800,0.000,0.000,179.839,-1,-1,-1,300.000);
	SetDynamicObjectMaterial(bcshop, 0, 14415, "carter_block_2", "mp_motel_carpet1", 0);
	bcshop = CreateDynamicObject(19400,-2952.649,2584.550,119.800,0.000,0.000,269.429,-1,-1,-1,300.000);
	SetDynamicObjectMaterial(bcshop, 0, 14415, "carter_block_2", "mp_motel_carpet1", 0);
	bcshop = CreateDynamicObject(19400,-2955.830,2584.580,119.800,0.000,0.000,269.429,-1,-1,-1,300.000);
	SetDynamicObjectMaterial(bcshop, 0, 14415, "carter_block_2", "mp_motel_carpet1", 0);
	bcshop = CreateDynamicObject(19427,-2958.060,2584.070,119.800,0.000,0.000,309.839,-1,-1,-1,300.000);
	SetDynamicObjectMaterial(bcshop, 0, 14415, "carter_block_2", "mp_motel_carpet1", 0);
	bcshop = CreateDynamicObject(19400,-2958.689,2581.979,119.800,0.000,0.000,358.670,-1,-1,-1,300.000);
	SetDynamicObjectMaterial(bcshop, 0, 14415, "carter_block_2", "mp_motel_carpet1", 0);
	bcshop = CreateDynamicObject(19400,-2958.760,2578.800,119.800,0.000,0.000,358.869,-1,-1,-1,300.000);
	SetDynamicObjectMaterial(bcshop, 0, 14415, "carter_block_2", "mp_motel_carpet1", 0);
	bcshop = CreateDynamicObject(19427,-2958.780,2576.409,119.800,0.000,0.000,0.000,-1,-1,-1,300.000);
	SetDynamicObjectMaterial(bcshop, 0, 14415, "carter_block_2", "mp_motel_carpet1", 0);
	bcshop = CreateDynamicObject(19366,-2956.969,2579.510,119.150,0.000,-90.000,0.009,-1,-1,-1,300.000);
	SetDynamicObjectMaterial(bcshop, 0, 13235, "ce_ground09", "des_ranchwall1", 0);
	bcshop = CreateDynamicObject(970,-2956.659,2577.919,118.620,0.000,0.000,0.000,-1,-1,-1,300.000);
	SetDynamicObjectMaterial(bcshop, 0, 8487, "ballyswater", "waterclear256", 0);
	bcshop = CreateDynamicObject(970,-2953.030,2579.260,118.620,0.000,0.000,40.630,-1,-1,-1,300.000);
	SetDynamicObjectMaterial(bcshop, 0, 8487, "ballyswater", "waterclear256", 0);
	bcshop = CreateDynamicObject(19366,-2954.290,2580.250,119.160,0.000,-90.000,40.639,-1,-1,-1,300.000);
	SetDynamicObjectMaterial(bcshop, 0, 13235, "ce_ground09", "des_ranchwall1", 0);
	bcshop = CreateDynamicObject(19366,-2956.320,2579.510,119.139,0.000,-90.000,0.009,-1,-1,-1,300.000);
	SetDynamicObjectMaterial(bcshop, 0, 13235, "ce_ground09", "des_ranchwall1", 0);
	bcshop = CreateDynamicObject(970,-2951.409,2582.659,118.620,0.000,0.000,88.510,-1,-1,-1,300.000);
	SetDynamicObjectMaterial(bcshop, 0, 8487, "ballyswater", "waterclear256", 0);
	bcshop = CreateDynamicObject(19366,-2953.790,2580.699,119.129,0.000,-90.000,40.549,-1,-1,-1,300.000);
	SetDynamicObjectMaterial(bcshop, 0, 13235, "ce_ground09", "des_ranchwall1", 0);
	bcshop = CreateDynamicObject(19366,-2953.010,2582.389,119.139,0.000,-90.000,88.849,-1,-1,-1,300.000);
	SetDynamicObjectMaterial(bcshop, 0, 13235, "ce_ground09", "des_ranchwall1", 0);
	bcshop = CreateDynamicObject(19366,-2952.989,2582.879,119.150,0.000,-90.000,88.819,-1,-1,-1,300.000);
	SetDynamicObjectMaterial(bcshop, 0, 13235, "ce_ground09", "des_ranchwall1", 0);
	bcshop = CreateDynamicObject(19366,-2956.139,2582.790,119.139,0.000,-90.000,88.050,-1,-1,-1,300.000);
	SetDynamicObjectMaterial(bcshop, 0, 13235, "ce_ground09", "des_ranchwall1", 0);
	bcshop = CreateDynamicObject(19366,-2957.030,2582.800,119.150,0.000,-90.000,88.050,-1,-1,-1,300.000);
	SetDynamicObjectMaterial(bcshop, 0, 13235, "ce_ground09", "des_ranchwall1", 0);
	bcshop = CreateDynamicObject(19446,-2954.000,2571.860,119.800,0.000,0.000,270.279,-1,-1,-1,300.000);
	SetDynamicObjectMaterial(bcshop, 0, 14415, "carter_block_2", "mp_motel_carpet1", 0);
	bcshop = CreateDynamicObject(19446,-2944.520,2571.899,119.800,0.000,0.000,270.279,-1,-1,-1,300.000);
	SetDynamicObjectMaterial(bcshop, 0, 14415, "carter_block_2", "mp_motel_carpet1", 0);
	bcshop = CreateDynamicObject(19446,-2942.939,2584.649,123.000,0.000,0.000,90.480,-1,-1,-1,300.000);
	SetDynamicObjectMaterial(bcshop, 0, 14415, "carter_block_2", "mp_motel_carpet1", 0);
	bcshop = CreateDynamicObject(19446,-2952.570,2584.629,123.000,0.000,0.000,89.760,-1,-1,-1,300.000);
	SetDynamicObjectMaterial(bcshop, 0, 14415, "carter_block_2", "mp_motel_carpet1", 0);
	bcshop = CreateDynamicObject(19427,-2958.030,2584.250,123.000,0.000,0.000,309.839,-1,-1,-1,300.000);
	SetDynamicObjectMaterial(bcshop, 0, 14415, "carter_block_2", "mp_motel_carpet1", 0);
	bcshop = CreateDynamicObject(19446,-2958.770,2579.199,123.000,0.000,0.000,179.050,-1,-1,-1,300.000);
	SetDynamicObjectMaterial(bcshop, 0, 14415, "carter_block_2", "mp_motel_carpet1", 0);
	bcshop = CreateDynamicObject(19446,-2958.899,2570.770,123.000,0.000,0.000,179.350,-1,-1,-1,300.000);
	SetDynamicObjectMaterial(bcshop, 0, 14415, "carter_block_2", "mp_motel_carpet1", 0);
	bcshop = CreateDynamicObject(19427,-2942.020,2584.040,123.000,0.000,0.000,222.210,-1,-1,-1,300.000);
	SetDynamicObjectMaterial(bcshop, 0, 14415, "carter_block_2", "mp_motel_carpet1", 0);
	bcshop = CreateDynamicObject(19446,-2941.580,2579.830,123.000,0.000,0.000,0.709,-1,-1,-1,300.000);
	SetDynamicObjectMaterial(bcshop, 0, 14415, "carter_block_2", "mp_motel_carpet1", 0);
	bcshop = CreateDynamicObject(19446,-2941.600,2570.219,123.000,0.000,0.000,359.239,-1,-1,-1,300.000);
	SetDynamicObjectMaterial(bcshop, 0, 14415, "carter_block_2", "mp_motel_carpet1", 0);
	bcshop = CreateDynamicObject(19446,-2944.510,2571.879,123.000,0.000,0.000,270.279,-1,-1,-1,300.000);
	SetDynamicObjectMaterial(bcshop, 0, 14415, "carter_block_2", "mp_motel_carpet1", 0);
	bcshop = CreateDynamicObject(19446,-2954.000,2571.840,123.000,0.000,0.000,270.279,-1,-1,-1,300.000);
	SetDynamicObjectMaterial(bcshop, 0, 14415, "carter_block_2", "mp_motel_carpet1", 0);
	bcshop = CreateDynamicObject(19427,-2942.060,2584.080,119.889,0.000,0.000,222.210,-1,-1,-1,300.000);
	SetDynamicObjectMaterial(bcshop, 0, 14415, "carter_block_2", "mp_motel_carpet1", 0);
	bcshop = CreateDynamicObject(19427,-2941.949,2572.300,119.889,0.000,0.000,135.600,-1,-1,-1,300.000);
	SetDynamicObjectMaterial(bcshop, 0, 14415, "carter_block_2", "mp_motel_carpet1", 0);
	bcshop = CreateDynamicObject(19427,-2941.959,2572.290,123.000,0.000,0.000,135.600,-1,-1,-1,300.000);
	SetDynamicObjectMaterial(bcshop, 0, 14415, "carter_block_2", "mp_motel_carpet1", 0);
	bcshop = CreateDynamicObject(19427,-2958.280,2572.399,119.889,0.000,0.000,44.220,-1,-1,-1,300.000);
	SetDynamicObjectMaterial(bcshop, 0, 14415, "carter_block_2", "mp_motel_carpet1", 0);
	bcshop = CreateDynamicObject(19427,-2958.260,2572.360,123.000,0.000,0.000,44.220,-1,-1,-1,300.000);
	SetDynamicObjectMaterial(bcshop, 0, 14415, "carter_block_2", "mp_motel_carpet1", 0);
	bcshop = CreateDynamicObject(19378,-2942.989,2579.840,124.620,0.000,90.000,0.000,-1,-1,-1,300.000);
	SetDynamicObjectMaterial(bcshop, 0, 8420, "carpark3_lvs", "greyground12802", 0);
	bcshop = CreateDynamicObject(19378,-2953.469,2579.870,124.620,0.000,90.000,359.660,-1,-1,-1,300.000);
	SetDynamicObjectMaterial(bcshop, 0, 8420, "carpark3_lvs", "greyground12802", 0);
	bcshop = CreateDynamicObject(19378,-2943.110,2570.310,124.620,0.000,90.000,0.000,-1,-1,-1,300.000);
	SetDynamicObjectMaterial(bcshop, 0, 8420, "carpark3_lvs", "greyground12802", 0);
	bcshop = CreateDynamicObject(19378,-2953.570,2570.270,124.620,0.000,90.000,0.000,-1,-1,-1,300.000);
	SetDynamicObjectMaterial(bcshop, 0, 8420, "carpark3_lvs", "greyground12802", 0);
	bcshop = CreateDynamicObject(1825,-2950.090,2575.310,118.000,0.000,0.000,0.000,-1,-1,-1,300.000);
	SetDynamicObjectMaterial(bcshop, 0, 14758, "sfmansion1", "ah_stainglass", 0);
	bcshop = CreateDynamicObject(1491,-2958.739,2573.000,117.910,0.000,0.000,313.640,-1,-1,-1,300.000);
	SetDynamicObjectMaterial(bcshop, 0, 14581, "ab_mafiasuitea", "kit_door1", 0);
	bcshop = CreateDynamicObject(16151,-2946.610,2583.679,118.470,0.000,0.000,91.949,-1,-1,-1,300.000);
	SetDynamicObjectMaterial(bcshop, 0, 14407, "carter_block", "zebra_skin", 0);
	SetDynamicObjectMaterial(bcshop, 3, 14407, "carter_block", "zebra_skin", 0);
	SetDynamicObjectMaterial(bcshop, 5, 14407, "carter_block", "zebra_skin", 0);
	bcshop = CreateDynamicObject(1649,-2958.689,2582.260,119.610,0.000,0.000,89.599,-1,-1,-1,300.000);
	bcshop = CreateDynamicObject(1649,-2952.270,2584.550,119.610,0.000,0.000,359.269,-1,-1,-1,300.000);
	bcshop = CreateDynamicObject(1649,-2956.239,2584.600,119.610,0.000,0.000,359.269,-1,-1,-1,300.000);
	bcshop = CreateDynamicObject(1649,-2958.800,2577.699,119.610,0.000,0.000,89.599,-1,-1,-1,300.000);
	bcshop = CreateDynamicObject(626,-2957.959,2577.550,119.870,0.000,0.000,37.880,-1,-1,-1,300.000);
	bcshop = CreateDynamicObject(626,-2950.719,2584.070,119.870,0.000,0.000,23.459,-1,-1,-1,300.000);
	bcshop = CreateDynamicObject(1731,-2954.219,2584.320,120.250,0.000,0.000,84.760,-1,-1,-1,300.000);
	bcshop = CreateDynamicObject(1731,-2957.840,2583.949,120.250,0.000,0.000,132.990,-1,-1,-1,300.000);
	bcshop = CreateDynamicObject(1731,-2958.489,2580.439,120.250,0.000,0.000,182.440,-1,-1,-1,300.000);
	bcshop = CreateDynamicObject(1709,-2943.399,2578.419,118.069,0.000,0.000,271.809,-1,-1,-1,300.000);
	bcshop = CreateDynamicObject(1775,-2941.110,2579.939,119.000,0.000,0.000,266.269,-1,-1,-1,300.000);
	bcshop = CreateDynamicObject(1825,-2943.459,2580.360,118.000,0.000,0.000,0.000,-1,-1,-1,300.000);
	bcshop = CreateDynamicObject(1825,-2946.780,2575.300,118.000,0.000,0.000,0.000,-1,-1,-1,300.000);
	bcshop = CreateDynamicObject(869,-2954.570,2581.350,118.650,0.000,0.000,0.000,-1,-1,-1,300.000);
	bcshop = CreateDynamicObject(869,-2953.330,2581.840,118.650,0.000,0.000,239.710,-1,-1,-1,300.000);
	bcshop = CreateDynamicObject(869,-2955.560,2580.070,118.650,0.000,0.000,8.689,-1,-1,-1,300.000);

	CreateDynamicPickup(1318, 23 , 2483.2205,-872.1638,2883.3989 ,-1 ,-1 ,-1,300.000);
	CreateDynamicPickup(1318, 23 , 1957.8014,-295.3812,4846.5444 ,-1 ,-1 ,-1,300.000);
	CreateDynamicPickup(1559,1,1482.30701, -1764.46826, 18.27360,-1 ,-1 ,-1,300.000);
	CreateDynamicPickup(1559,1,384.808624,173.804992,1008.382812,-1 ,-1 ,-1,300.000);
	return 1;
}

public OnGameModeExit()
{
	SaveHouse();
	SaveCars();
	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
	SetPlayerPos(playerid, 1958.3783, 1343.1572, 15.3746);
	SetPlayerCameraPos(playerid, 1958.3783, 1343.1572, 15.3746);
	SetPlayerCameraLookAt(playerid, 1958.3783, 1343.1572, 15.3746);
	return 1;
}

public OnPlayerConnect(playerid)
{
    GetPlayerName(playerid, Name(playerid) , MAX_PLAYER_NAME);
    TogglePlayerSpectating(playerid, 1);
	TogglePlayerControllable(playerid,0);
	RemoveBuildingForPlayer(playerid, 4024, 1479.8672, -1790.3984, 56.0234, 0.25);
 	RemoveBuildingForPlayer(playerid, 4044, 1481.1875, -1785.0703, 22.3828, 0.25);
 	RemoveBuildingForPlayer(playerid, 1527, 1448.2344, -1755.8984, 14.5234, 0.25);
  	RemoveBuildingForPlayer(playerid, 1294, 1393.2734, -1796.3516, 16.9766, 0.25);
 	RemoveBuildingForPlayer(playerid, 1226, 1451.6250, -1727.6719, 16.4219, 0.25);
   	RemoveBuildingForPlayer(playerid, 4002, 1479.8672, -1790.3984, 56.0234, 0.25);
    RemoveBuildingForPlayer(playerid, 3980, 1481.1875, -1785.0703, 22.3828, 0.25);
    RemoveBuildingForPlayer(playerid, 4003, 1481.0781, -1747.0313, 33.5234, 0.25);
    RemoveBuildingForPlayer(playerid, 1226, 1467.9844, -1727.6719, 16.4219, 0.25);
    RemoveBuildingForPlayer(playerid, 1226, 1485.1719, -1727.6719, 16.4219, 0.25);
    RemoveBuildingForPlayer(playerid, 1283, 1513.2344, -1732.9219, 15.6250, 0.25);
    for(new i=0;i<6;i++) {PlayerTextDrawHide(playerid,Textdrawl[playerid][i]); PlayerTextDrawDestroy(playerid,Textdrawl[playerid][i]);}
    for(new i=0;i<12;i++) {PlayerTextDrawHide(playerid,Textdrawr[playerid][i]); PlayerTextDrawDestroy(playerid,Textdrawr[playerid][i]);}
	format(sesql,sizeof(ses),"SELECT * FROM `players` WHERE `Name` = '%s' LIMIT 1",Name(playerid));
	mysql_function_query(pl,sesql, true, "PlayerCheck", "d", playerid);
	ClearMess(playerid);
	format(ses,sizeof(ses), COL_GREEN"{BigBazewMod}\n[Server]Привет "COL_APELS"%s"COL_GREEN", добро пожаловать",Name(playerid));
	SendClientMessage(playerid,-1,ses);
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	if(GetPVarInt(playerid,"Login") == 0){printf("%s disconnect and no save",Name(playerid)); return 1;}
	SavePlayer(playerid);
	printf("%s disconnect and save",Name(playerid));
	memset(PlayerInfo[ playerid ], 0, _:pInfo ) ;
	return 1;
}
public OnPlayerCommandReceived(playerid, cmd[], params[], flags)
{
	if(GetPVarInt(playerid,"Login") == 0) 
	{
		SendClientMessage(playerid, -1, "You are not loggin");
		return 0;
	}
	return 1;
}
public OnPlayerSpawn(playerid)
{
    SetPlayerSkin(playerid,PlayerInfo[playerid][pSkin]);
	SetPlayerPos(playerid,PlayerInfo[playerid][pPos][0],PlayerInfo[playerid][pPos][1],PlayerInfo[playerid][pPos][2]);
	SetPlayerInterior(playerid,PlayerInfo[playerid][pIntW][0]);
	SetPlayerVirtualWorld(playerid,PlayerInfo[playerid][pIntW][1]);
	CancelSelectTextDraw(playerid);
	SetCameraBehindPlayer(playerid);
	if(GetPVarInt(playerid,"Pbcar"))
	{
		PutPlayerInVehicle(playerid,GetPVarInt(playerid,"Homew"),0);
		SetPVarInt(playerid,"Pbcar",0);
	}
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
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
	return 1;
}
//Commads

cmd:newhouse(playerid,params[])
{
    SetPVarInt(playerid,"Homew",-1);
    for(new i =0;i<allhouse;i++)
	{
 		if(HouseInfo[i][hBuy] != -1) continue;
 		if(HouseInfo[i][hBuy] == -1) {SetPVarInt(playerid,"Homew",i); break;}
	}
	ShowHDialog(playerid);
	return 1;
}
/*cmd:newcars(playerid,params[])
{
    SetPVarInt(playerid,"Carsw",-1);
    for(new i =0;i<allcars;i++)
	{
 		if(CarsInfo[i][cBuy] != -1) continue;
 		if(CarsInfo[i][cBuy] == -1) {SetPVarInt(playerid,"Carsw",i); break;}
	}
	//ShowCDialog(playerid);
	return 1;
}*/
cmd:dellhouse(playerid,params[])
{
	if(sscanf(params,"d",params[0])) return SendClientMessage(playerid,-1, COL_WHITE"Использование: "COL_APELS" /dellhouse [id]");
	if(params[0] > allhouse) return SendClientMessage(playerid,-1,COL_RED"[Ошибка]"COL_WHITE" ID дома указан неверно!");
	if(HouseInfo[params[0]][hBuy] == -1) return SendClientMessage(playerid,-1,COL_RED"[Ошибка]"COL_WHITE" Дом уже продан");
	SetPVarInt(playerid,"Homew",params[0]);
	format(ses,sizeof(ses),"Вы действительно желаете удалить дом %i ,владлец %s",params[0],Ownerh(params[0]));
	Dialog_Show(playerid, DellHouse, DIALOG_STYLE_MSGBOX, "Удаления дома", ses, "Принять", "Отмена");
	return 1;
}
cmd:rellhouse(playerid,params[])
{
	if(sscanf(params,"d",params[0])) return SendClientMessage(playerid,-1,COL_WHITE"Использование: "COL_APELS" /rellhouse [id]");
	if(params[0] > allhouse) return SendClientMessage(playerid,-1,COL_RED"[Ошибка]"COL_WHITE" Неверный ид дома");
	if(!HouseInfo[params[0]][hBuy]) return SendClientMessage(playerid,-1,COL_RED"[Ошибка]"COL_WHITE" Дом уже продан");
	SetPVarInt(playerid,"Homew",params[0]);
	format(ses,sizeof(ses),"Вы действительно желаете сделать дом %i ,доступным для продажи",params[0]);
	Dialog_Show(playerid, RellHouse, DIALOG_STYLE_MSGBOX, "Удаления дома", ses, "Принять", "Отмена");
	return 1;
}
cmd:edithouse(playerid,params[])
{
    if(sscanf(params,"d",params[0])) return SendClientMessage(playerid,-1,COL_WHITE"Использование: "COL_APELS" /dellhouse [id]");
	if(params[0] > allhouse) return SendClientMessage(playerid,-1,COL_RED"[Ошибка]"COL_WHITE" Неверный ид дома");
	SetPVarInt(playerid,"Homew",params[0]);
	ShowHEDialog(playerid,GetPVarInt(playerid,"Homew"));
	return 1;
}
cmd:listhouse(playerid,params[])
{
	format(sesql,sizeof(sesql),"",1);
	for(new i=0;i<allhouse;i++)
	{
	    format(sesql,sizeof(sesql),"%sДом {00BFFF}[%i] Владелец {00BFFF}[%s] Статус {00BFFF}[%i]\n",sesql,i,Ownerh(i),HouseInfo[i][hBuy]);
	}
	Dialog_Show(playerid, ListHouse, DIALOG_STYLE_LIST, "Лист домов", sesql, "Выбор", "Отмена");
	return 1;
}
Dialog:ListHouse(playerid, response, listitem, inputtext[])
{
	if(!response) return 1;
	SetPVarInt(playerid,"Homew",listitem);
	ShowHEDialog(playerid,GetPVarInt(playerid,"Homew"));
	return 1;
}
cmd:check(playerid,params[])
{
	if(sscanf(params,"d",params[0])) return SendClientMessage(playerid,COLOR_GREEN,"/check [num]");
	switch(params[0])
	{
		case 0:SetPlayerPos(playerid,2483.2205,-872.1638,2883.3989);
		case 1:SetPlayerPos(playerid,1957.8014,-295.3812,4846.5444);
		case 2:SetPlayerPos(playerid,1421.3472,-1725.2466,14.5469);
		case 3:SetPlayerPos(playerid,-2956.0679,2574.0181,119.0859);
	}
	return 1;
}
cmd:upa(playerid,params[])
{
	if(!GetPlayerVehicleID(playerid)) return SendClientMessage(playerid,COLOR_RED,"Только для авто");
	if(sscanf(params,"d",params[0])) return SendClientMessage(playerid,COLOR_GREEN,"/upa [num]");
	switch(params[0])
	{
		case 0:SetVehiclePos(GetPlayerVehicleID(playerid),-2711.0425,205.4991,3.9071);
 		case 1:SetVehiclePos(GetPlayerVehicleID(playerid),1413.1434,-1730.9310,13.3906);
 	}
	return 1;
}
cmd:veh(playerid,params[])
{
	if(sscanf(params,"d",params[0])) return SendClientMessage(playerid,COLOR_GREEN,"/veh [id]");
	new Float:x,Float:y,Float:z;
	GetPlayerPos(playerid,x,y,z);
	SetPVarInt(playerid,"Homew",CreateVehicle(params[0],x,y,z,0,random(255),random(255),300));
	format(ses,sizeof(ses),"id - %i",NameCar[GetVehicleModel(GetPVarInt(playerid,"Homew"))-400]);
	SendClientMessage(playerid,COLOR_RED,ses);
	return 1;
}
cmd:saveall(playerid,params[])
{
	SaveHouse();
	SaveCars();
	return 1;
}
cmd:camh(playerid,params[])
{
	new Float:p[3],Float:pp[3],Float:ppp[2];
	ppp[0]=1405.3464;ppp[1]=-1726.6882;
	new Float:dist = 5.0;
	GetPlayerCameraFrontVector(playerid,p[0],p[1],p[2]);
	GetPlayerCameraPos(playerid,pp[0],pp[1],pp[2]);
	SetPlayerCameraLookAt(playerid,ppp[0],ppp[0],pp[2]);
	SetPlayerCameraPos(playerid,pp[0]-dist*p[0],pp[1]-dist*p[1],pp[2]+4);
	return 1;
}

cmd:camp(playerid,params[])
{
	SetCameraBehindPlayer(playerid);
	return 1;
}

cmd:buyveh(playerid,params[])
{
    new i;
	for(i=0;i<MAX_CARS;i++)
	{
	    if(CarsInfo[i][cBuy] == -1) break;
	}
	printf("%i",i);
	TogglePlayerControllable(playerid,0);
	TogglePlayerSpectating(playerid, 1);
	SetPlayerVirtualWorld(playerid,playerid);
	InterpolateCameraPos(playerid,-2957.0149,2573.1353,123.0859,-2944.2605,2578.1782,123.0859,50000,CAMERA_MOVE);
	InterpolateCameraLookAt(playerid,-2955.4177,2581.3289,119.8971,-2955.4177,2581.3289,119.8971,5000,CAMERA_MOVE);
	TextDrawC(playerid,2);
	SetPVarInt(playerid,"Pla",0);
	SetPVarInt(playerid,"HPrice",cafb[GetPVarInt(playerid,"Pla")][1]);
	SetPVarInt(playerid,"Homew",CreateVehicle(cafb[GetPVarInt(playerid,"Pla")][0],-2955.4177,2581.3289,119.8971,224.7385,random(255),random(255),0));
	SetVehicleVirtualWorld(GetPVarInt(playerid,"Homew"),playerid);
	format(ses,sizeof(ses),"Name: ~g~%s",NameCar[GetVehicleModel(GetPVarInt(playerid,"Homew")) -400]);
	PlayerTextDrawSetString(playerid,Textbc[playerid][1],ses);
	format(ses,sizeof(ses),"Price: ~g~%i$",GetPVarInt(playerid,"HPrice"));
	PlayerTextDrawSetString(playerid,Textbc[playerid][2],ses);
	SetPVarInt(playerid,"Pbcar",1);
	GetPlayerPos(playerid,PlayerInfo[playerid][pPos][0],PlayerInfo[playerid][pPos][1],PlayerInfo[playerid][pPos][2]);
	return 1;
}
cmd:sellveh(playerid,params[])
{
	if(Ownerc(carsb[GetPlayerVehicleID(playerid)]) != Name(playerid)) return SendClientMessage(playerid,-1,"Авто не ваше");
	SetPVarInt(playerid,"HomeW",carsb[GetPlayerVehicleID(playerid)]);
	SendClientMessage(playerid,-1,"Авто ваше");
	format(ses,sizeof(ses),""COL_YELLOW"Вы дейстительно желаете продать "COL_GREEN"%s , "COL_YELLOW"за "COL_GREEN"%i $",NameCar[GetVehicleModel(GetPlayerVehicleID(playerid)) - 400],CarsInfo[carsb[GetPlayerVehicleID(playerid)]][cPrice]);
	Dialog_Show(playerid, CarSell, DIALOG_STYLE_MSGBOX, "Продажа авто", ses, "Выбор", "Отмена");
	return 1;
}
cmd:cmds(playerid,params[])
{
	format(ses,sizeof(ses),"newhouse,dellhouse,rellhouse,edithouse,listhouse,check,upa,veh,saveall,camh,camp,buyveh,sellveh");
	SendClientMessage(playerid,COLOR_RED,ses);
	return 1;
}
Dialog:CarSell(playerid, response, listitem, inputtext[])
{
	if(!response) return 0;
    strmid(Ownerc(GetPVarInt(playerid,"Homew")),"None",0,24,24);
	CarsInfo[GetPVarInt(playerid,"Homew")][cBuy] = 0;
	format(ses,sizeof(ses),"{00cc33}Авто продается !\n{0066cc}Стоимость - {00cc33}%i\n\n{0066cc}Дом № {00cc33}%i",CarsInfo[GetPVarInt(playerid,"Homew")][cPrice],GetPVarInt(playerid,"Homew"));
	UpdateDynamic3DTextLabelText(tcbuy[GetPVarInt(playerid,"Homew")],0x1E90FFAA,ses);
	return 1;
}
Dialog:RellHouse(playerid, response, listitem, inputtext[])
{
    strmid(Ownerh(GetPVarInt(playerid,"Homew")),"None",0,24,24);
	HouseInfo[GetPVarInt(playerid,"Homew")][hBuy] = 0;
	DestroyDynamicPickup(buyhome[GetPVarInt(playerid,"Homew")]);
	DestroyDynamicMapIcon(buyico[GetPVarInt(playerid,"Homew")]);
	buyhome[GetPVarInt(playerid,"Homew")] = CreateDynamicPickup(1273, 23 , HouseInfo[GetPVarInt(playerid,"Homew")][hEnt][0],HouseInfo[GetPVarInt(playerid,"Homew")][hEnt][1],HouseInfo[GetPVarInt(playerid,"Homew")][hEnt][2] ,0,-1,-1);
	buyico[GetPVarInt(playerid,"Homew")] = CreateDynamicMapIcon(HouseInfo[GetPVarInt(playerid,"Homew")][hEnt][0],HouseInfo[GetPVarInt(playerid,"Homew")][hEnt][1],HouseInfo[GetPVarInt(playerid,"Homew")][hEnt][2],31, 0x1E90FFAA,0,-1,-1);
	format(ses,sizeof(ses),"{00cc33}Дом продается !\n{0066cc}Стоимость - {00cc33}%i\n{0066cc}Уровень - {00cc33}%i\n{0066cc}Дом № {00cc33}%i",HouseInfo[GetPVarInt(playerid,"Homew")][hPrice],HouseInfo[GetPVarInt(playerid,"Homew")][hLevel],GetPVarInt(playerid,"Homew"));
	UpdateDynamic3DTextLabelText(thbuy[GetPVarInt(playerid,"Homew")],0x1E90FFAA,ses);
	format(ses,sizeof(ses),COL_LIGHTBLUE"Дом "COL_APELS"%i "COL_LIGHTBLUE"успешно выставлен на продажу",GetPVarInt(playerid,"Homew"));
	SendClientMessage(playerid,-1,ses);
	return 1;
}
Dialog:DellHouse(playerid, response, listitem, inputtext[])
{
	if(!response) return 1;
	HouseInfo[GetPVarInt(playerid,"Homew")][hBuy] = -1;
	DestroyDynamicPickup(buyhome[GetPVarInt(playerid,"Homew")]);
	DestroyDynamicMapIcon(buyico[GetPVarInt(playerid,"Homew")]);
	DestroyDynamic3DTextLabel(thbuy[GetPVarInt(playerid,"Homew")]);
	SendClientMessage(playerid,COLOR_GOLD,"Дом успешно удален");
	return 1;
}
Dialog:HouseAdd(playerid, response, listitem, inputtext[])
{
	if(!response) {SetCameraBehindPlayer(playerid);return 1;}
	switch(listitem)
	{
	    case 0:{Dialog_Show(playerid, HouseAdd0, DIALOG_STYLE_INPUT, "Настройка нового дома", "Введите цену дома", "Ввод", "Отмена"); return 1;}
	    case 2:{Dialog_Show(playerid, HouseAdd2, DIALOG_STYLE_LIST, "Настройка нового дома", "Интер маленьки\nПобольше интерер", "Ввод", "Отмена"); return 1;}
	    case 1:{Dialog_Show(playerid, HouseAdd1, DIALOG_STYLE_INPUT, "Настройка нового дома", "Введите уровень дома", "Ввод", "Отмена"); return 1;}
		case 3:
		{
			new Float:hx,Float:hy,Float:hz;
			GetPlayerPos(playerid,hx,hy,hz);
			new Float:p[3],Float:pp[3];
			new Float:dist = 5.0;
			GetPlayerCameraFrontVector(playerid,p[0],p[1],p[2]);
			GetPlayerCameraPos(playerid,pp[0],pp[1],pp[2]);
			SetPlayerCameraLookAt(playerid,hx,hy,hz);
			SetPlayerCameraPos(playerid,pp[0]-dist*p[0],pp[1]-dist*p[1],pp[2]+4);
			SetPVarInt(playerid,"ObjectH",CreateObject(1273, hx, hy, hz,  0.00, 0.00, 0.00));
			EditObject(playerid,GetPVarInt(playerid,"ObjectH"));
		}
		case 4:
		{
		    if(GetPVarInt(playerid,"HInt") == 0)
			{
			    SendClientMessage(playerid,-1,COL_RED"[Ошибка]"COL_WHITE" Установите интерер");
				ShowHDialog(playerid);
				return 1;
			}
			if(GetPVarInt(playerid,"ObjectH") == 0)
			{
			    SendClientMessage(playerid,-1,COL_RED"[Ошибка]"COL_WHITE" Установите обект");
				ShowHDialog(playerid);
				return 1;
			}
			SendClientMessage(playerid,COLOR_GOLD,"Дом создан");
			SetCameraBehindPlayer(playerid);
			SetPVarInt(playerid,"ObjectH",0);
			CreateHouse(GetPVarInt(playerid,"Homew"),GetPVarInt(playerid,"HPrice"),GetPVarInt(playerid,"HLevel"),GetPVarFloat(playerid,"HPosx"),GetPVarFloat(playerid,"HPosy"),GetPVarFloat(playerid,"HPosz"),GetPVarInt(playerid,"HInt"));
          	return 1;
		}
	    
	}
 	return 1;
}
Dialog:HouseEdit(playerid, response, listitem, inputtext[])
{
	if(!response) return 1;
	switch(listitem)
	{
	    case 0:{Dialog_Show(playerid, HouseEdit0, DIALOG_STYLE_INPUT, "Настройка дома", "Введите владельца дома", "Ввод", "Отмена"); return 1;}
	    case 1:{Dialog_Show(playerid, HouseEdit1, DIALOG_STYLE_INPUT, "Настройка дома", "Введите цену дома", "Ввод", "Отмена"); return 1;}
	    case 2:{Dialog_Show(playerid, HouseEdit2, DIALOG_STYLE_INPUT, "Настройка дома", "Введите уровень дома", "Ввод", "Отмена"); return 1;}
	    case 3:{Dialog_Show(playerid, HouseEdit3, DIALOG_STYLE_LIST, "Настройка дома", "Интер маленьки\nПобольше интерер", "Ввод", "Отмена"); return 1;}
	    case 4:{Dialog_Show(playerid, HouseEdit4, DIALOG_STYLE_LIST, "Настройка дома", "Удален\nПродается\nКуплен", "Ввод", "Отмена"); return 1;}
		case 5:
		{
		    if(HouseInfo[GetPVarInt(playerid,"Homew")][hBuy] == -1) {ShowHEDialog(playerid,GetPVarInt(playerid,"Homew")); return SendClientMessage(playerid,-1,"Дом удален");}
		    if(!IsPlayerInRangeOfPoint(playerid,5,HouseInfo[GetPVarInt(playerid,"Homew")][hEnt][0],HouseInfo[GetPVarInt(playerid,"Homew")][hEnt][1],HouseInfo[GetPVarInt(playerid,"Homew")][hEnt][2])) return SendClientMessage(playerid,COLOR_LIGHTRED,"Далеко от дома");
			SetPVarInt(playerid,"ObjectHE",CreateObject(1273, HouseInfo[GetPVarInt(playerid,"Homew")][hEnt][0], HouseInfo[GetPVarInt(playerid,"Homew")][hEnt][1], HouseInfo[GetPVarInt(playerid,"Homew")][hEnt][2],  0.00, 0.00, 0.00));
			EditObject(playerid,GetPVarInt(playerid,"ObjectHE"));
		}

	}
 	return 1;
}

Dialog:HouseEdit0(playerid, response, listitem, inputtext[])
{
	if(!response)
	{
    	ShowHEDialog(playerid,GetPVarInt(playerid,"Homew"));
		return 1;
	}
	if(strlen(inputtext) > 24){ ShowHEDialog(playerid,GetPVarInt(playerid,"Homew"));	return SendClientMessage(playerid,-1,COL_RED"[Ошибка]"COL_WHITE" Использовано больше 24 символов");}
	strmid(Ownerh(GetPVarInt(playerid,"Homew")),inputtext,0,24,24);
	if(HouseInfo[GetPVarInt(playerid,"Homew")][hBuy] == 1)
	{
	    format(ses,256,"{993300}Владец - {006699}%s\n{993300}{0066cc}Дом № {006699}%i",Ownerh(GetPVarInt(playerid,"Homew")),GetPVarInt(playerid,"Homew"));
		UpdateDynamic3DTextLabelText(thbuy[GetPVarInt(playerid,"Homew")],0x1E90FFAA,ses);
	}
	else if(HouseInfo[GetPVarInt(playerid,"Homew")][hBuy] == 0)
	{
	    format(ses,sizeof(ses),"{00cc33}Дом продается !\n{0066cc}Стоимость - {00cc33}%i\n{0066cc}Уровень - {00cc33}%i\n{0066cc}Дом № {00cc33}%i",HouseInfo[GetPVarInt(playerid,"Homew")][hPrice],HouseInfo[GetPVarInt(playerid,"Homew")][hLevel],GetPVarInt(playerid,"Homew"));
	    UpdateDynamic3DTextLabelText(thbuy[GetPVarInt(playerid,"Homew")],0x1E90FFAA,ses);
	}
	ShowHEDialog(playerid,GetPVarInt(playerid,"Homew"));
	return 1;
}
Dialog:HouseEdit1(playerid, response, listitem, inputtext[])
{
	if(!response)
	{
    	ShowHEDialog(playerid,GetPVarInt(playerid,"Homew"));
		return 1;
	}
	HouseInfo[GetPVarInt(playerid,"Homew")][hPrice] = strval(inputtext);
	if(HouseInfo[GetPVarInt(playerid,"Homew")][hBuy] == 1)
	{
	    format(ses,256,"{993300}Владец - {006699}%s\n{993300}{0066cc}Дом № {006699}%i",Ownerh(GetPVarInt(playerid,"Homew")),GetPVarInt(playerid,"Homew"));
		UpdateDynamic3DTextLabelText(thbuy[GetPVarInt(playerid,"Homew")],0x1E90FFAA,ses);
	}
	else if(HouseInfo[GetPVarInt(playerid,"Homew")][hBuy] == 0)
	{
	    format(ses,sizeof(ses),"{00cc33}Дом продается !\n{0066cc}Стоимость - {00cc33}%i\n{0066cc}Уровень - {00cc33}%i\n{0066cc}Дом № {00cc33}%i",HouseInfo[GetPVarInt(playerid,"Homew")][hPrice],HouseInfo[GetPVarInt(playerid,"Homew")][hLevel],GetPVarInt(playerid,"Homew"));
	    UpdateDynamic3DTextLabelText(thbuy[GetPVarInt(playerid,"Homew")],0x1E90FFAA,ses);
	}
	ShowHEDialog(playerid,GetPVarInt(playerid,"Homew"));
	return 1;
}

public OnPlayerCommandPerformed(playerid, cmd[], params[], result, flags)
{
	if(result == -1) SendClientMessage(playerid, COLOR_WHITE, "SERVER: Все команды я писал в вк в диалоге , посмотри там");
	return 1;
}

Dialog:HouseEdit2(playerid, response, listitem, inputtext[])
{
	if(!response)
	{
    	ShowHEDialog(playerid,GetPVarInt(playerid,"Homew"));
		return 1;
	}
	HouseInfo[GetPVarInt(playerid,"Homew")][hLevel] = strval(inputtext);
	if(HouseInfo[GetPVarInt(playerid,"Homew")][hBuy] == 1)
	{
	    format(ses,256,"{993300}Владец - {006699}%s\n{993300}{0066cc}Дом № {006699}%i",Ownerh(GetPVarInt(playerid,"Homew")),GetPVarInt(playerid,"Homew"));
		UpdateDynamic3DTextLabelText(thbuy[GetPVarInt(playerid,"Homew")],0x1E90FFAA,ses);
	}
	else if(HouseInfo[GetPVarInt(playerid,"Homew")][hBuy] == 0)
	{
	    format(ses,sizeof(ses),"{00cc33}Дом продается !\n{0066cc}Стоимость - {00cc33}%i\n{0066cc}Уровень - {00cc33}%i\n{0066cc}Дом № {00cc33}%i",HouseInfo[GetPVarInt(playerid,"Homew")][hPrice],HouseInfo[GetPVarInt(playerid,"Homew")][hLevel],GetPVarInt(playerid,"Homew"));
	    UpdateDynamic3DTextLabelText(thbuy[GetPVarInt(playerid,"Homew")],0x1E90FFAA,ses);
	}
	ShowHEDialog(playerid,GetPVarInt(playerid,"Homew"));
	return 1;
}
Dialog:HouseEdit3(playerid, response, listitem, inputtext[])
{
	if(!response)
	{
    	ShowHEDialog(playerid,GetPVarInt(playerid,"Homew"));
		return 1;
	}
	switch(listitem)
	{
		case 0:
		{
		    HouseInfo[GetPVarInt(playerid,"Homew")][hExt][0] = 2483.2205;
			HouseInfo[GetPVarInt(playerid,"Homew")][hExt][1] = -872.1638;
			HouseInfo[GetPVarInt(playerid,"Homew")][hExt][2] = 2883.3989;
			HouseInfo[GetPVarInt(playerid,"Homew")][hInt] = 1;
		}
		case 1:
		{
		    HouseInfo[GetPVarInt(playerid,"Homew")][hExt][0] = 1957.8014;
			HouseInfo[GetPVarInt(playerid,"Homew")][hExt][1] = -295.3812;
			HouseInfo[GetPVarInt(playerid,"Homew")][hExt][2] = 4846.5444;
			HouseInfo[GetPVarInt(playerid,"Homew")][hInt] = 2;
		}
	}
	ShowHEDialog(playerid,GetPVarInt(playerid,"Homew"));
	return 1;
}
Dialog:HouseEdit4(playerid, response, listitem, inputtext[])
{
	if(!response)
	{
    	ShowHEDialog(playerid,GetPVarInt(playerid,"Homew"));
		return 1;
	}
	switch(listitem)
	{
		case 0:
		{
		    HouseInfo[GetPVarInt(playerid,"Homew")][hBuy] = -1;
			DestroyDynamicPickup(buyhome[GetPVarInt(playerid,"Homew")]);
			DestroyDynamicMapIcon(buyico[GetPVarInt(playerid,"Homew")]);
			DestroyDynamic3DTextLabel(thbuy[GetPVarInt(playerid,"Homew")]);
			SendClientMessage(playerid,COLOR_GOLD,"Дом успешно удален");
			ShowHEDialog(playerid,GetPVarInt(playerid,"Homew"));
			return 1;
		}
		case 1:
		{
		    strmid(Ownerh(GetPVarInt(playerid,"Homew")),"None",0,24,24);
	    	HouseInfo[GetPVarInt(playerid,"Homew")][hBuy] = 0;
	    	DestroyDynamicPickup(buyhome[GetPVarInt(playerid,"Homew")]);
	    	DestroyDynamicMapIcon(buyico[GetPVarInt(playerid,"Homew")]);
	    	DestroyDynamic3DTextLabel(thbuy[GetPVarInt(playerid,"Homew")]);
	    	buyhome[GetPVarInt(playerid,"Homew")] = CreateDynamicPickup(1273, 23 , HouseInfo[GetPVarInt(playerid,"Homew")][hEnt][0],HouseInfo[GetPVarInt(playerid,"Homew")][hEnt][1],HouseInfo[GetPVarInt(playerid,"Homew")][hEnt][2] ,0,-1,-1);
	    	buyico[GetPVarInt(playerid,"Homew")] = CreateDynamicMapIcon(HouseInfo[GetPVarInt(playerid,"Homew")][hEnt][0],HouseInfo[GetPVarInt(playerid,"Homew")][hEnt][1],HouseInfo[GetPVarInt(playerid,"Homew")][hEnt][2],31, 0x1E90FFAA,0,-1,-1);
	    	format(ses,sizeof(ses),"{00cc33}Дом продается !\n{0066cc}Стоимость - {00cc33}%i\n{0066cc}Уровень - {00cc33}%i\n{0066cc}Дом № {00cc33}%i",HouseInfo[GetPVarInt(playerid,"Homew")][hPrice],HouseInfo[GetPVarInt(playerid,"Homew")][hLevel],GetPVarInt(playerid,"Homew"));
	    	thbuy[GetPVarInt(playerid,"Homew")] = CreateDynamic3DTextLabel(ses,0x1E90FFAA,HouseInfo[GetPVarInt(playerid,"Homew")][hEnt][0],HouseInfo[GetPVarInt(playerid,"Homew")][hEnt][1],HouseInfo[GetPVarInt(playerid,"Homew")][hEnt][2]+0.6,100,INVALID_PLAYER_ID,INVALID_VEHICLE_ID,0,0,-1,-1);
	    	format(ses,sizeof(ses),COL_WHITE"Дом "COL_APELS"%i"COL_WHITE" успешно выставлен на продажу",GetPVarInt(playerid,"Homew"));
	    	SendClientMessage(playerid,-1,ses);
	    	ShowHEDialog(playerid,GetPVarInt(playerid,"Homew"));
			return 1;
		}
		case 2:
		{
		    HouseInfo[GetPVarInt(playerid,"Homew")][hBuy] = 1;
		    DestroyDynamicPickup(buyhome[GetPVarInt(playerid,"Homew")]);
			DestroyDynamicMapIcon(buyico[GetPVarInt(playerid,"Homew")]);
			DestroyDynamic3DTextLabel(thbuy[GetPVarInt(playerid,"Homew")]);
  	      	buyhome[GetPVarInt(playerid,"Homew")] = CreateDynamicPickup(1318, 23 , HouseInfo[GetPVarInt(playerid,"Homew")][hEnt][0],HouseInfo[GetPVarInt(playerid,"Homew")][hEnt][1],HouseInfo[GetPVarInt(playerid,"Homew")][hEnt][2] ,0,-1,-1);
  	      	buyico[GetPVarInt(playerid,"Homew")] = CreateDynamicMapIcon(HouseInfo[GetPVarInt(playerid,"Homew")][hEnt][0],HouseInfo[GetPVarInt(playerid,"Homew")][hEnt][1],HouseInfo[GetPVarInt(playerid,"Homew")][hEnt][2],32, 0x1E90FFAA,0,-1,-1);
  	      	format(ses,sizeof(ses),"{993300}Владец - {006699}%s\n{993300}{0066cc}Дом № {006699}%i",Ownerh(GetPVarInt(playerid,"Homew")),GetPVarInt(playerid,"Homew"));
  	      	thbuy[GetPVarInt(playerid,"Homew")] = CreateDynamic3DTextLabel(ses,0x1E90FFAA,HouseInfo[GetPVarInt(playerid,"Homew")][hEnt][0],HouseInfo[GetPVarInt(playerid,"Homew")][hEnt][1],HouseInfo[GetPVarInt(playerid,"Homew")][hEnt][2]+0.6,100,INVALID_PLAYER_ID,INVALID_VEHICLE_ID,0,0,-1,-1);
  	      	format(ses,sizeof(ses),COL_WHITE"Дом "COL_APELS"%i"COL_WHITE" успешно куплен для %s",GetPVarInt(playerid,"Homew"),Ownerh(GetPVarInt(playerid,"Homew")));
  	      	SendClientMessage(playerid,-1,ses);
  	      	ShowHEDialog(playerid,GetPVarInt(playerid,"Homew"));
			return 1;
		}
	}
	ShowHEDialog(playerid,GetPVarInt(playerid,"Homew"));
	return 1;
}
forward Pokaz(playerid);

public Pokaz(playerid)
{
	SetCameraBehindPlayer(playerid);
 	TogglePlayerControllable(playerid,1);
	return 1;
}
Dialog:HouseAdd0(playerid, response, listitem, inputtext[])
{
	if(!response)
	{
    	ShowHDialog(playerid);
		return 1;
	}
	SetPVarInt(playerid,"HPrice",strval(inputtext));
	ShowHDialog(playerid);
	return 1;
	
}
Dialog:HouseAdd1(playerid, response, listitem, inputtext[])
{
    if(!response || strval(inputtext) < 0)
	{
    	ShowHDialog(playerid);
		return 1;
	}
	SetPVarInt(playerid,"HLevel",strval(inputtext));
	ShowHDialog(playerid);
	return 1;

}
Dialog:HouseAdd2(playerid, response, listitem, inputtext[])
{
	if(!response)
	{
    	ShowHDialog(playerid);
		return 1;
	}
	SetPVarInt(playerid,"HInt",listitem+1);
	ShowHDialog(playerid);
	return 1;
}
public OnPlayerEditObject(playerid, playerobject, objectid, response, Float:fX, Float:fY, Float:fZ, Float:fRotX, Float:fRotY, Float:fRotZ)
{
	if(response == EDIT_RESPONSE_FINAL)
	{
		if(objectid == GetPVarInt(playerid,"ObjectH"))
		{
			SetPVarFloat(playerid,"HPosx",fX);
			SetPVarFloat(playerid,"HPosy",fY);
			SetPVarFloat(playerid,"HPosz",fZ);
			DestroyObject(GetPVarInt(playerid,"ObjectH"));
			ShowHDialog(playerid);
		}
		else if(objectid == GetPVarInt(playerid,"ObjectHE"))
		{
			HouseInfo[GetPVarInt(playerid,"Homew")][hEnt][0] = fX;
			HouseInfo[GetPVarInt(playerid,"Homew")][hEnt][1] = fY;
			HouseInfo[GetPVarInt(playerid,"Homew")][hEnt][2] = fZ;
			DestroyObject(GetPVarInt(playerid,"ObjectHE"));
			switch(HouseInfo[GetPVarInt(playerid,"Homew")][hBuy])
			{
				case 0:
				{
				    DestroyDynamicPickup(buyhome[GetPVarInt(playerid,"Homew")]);
 				   	DestroyDynamicMapIcon(buyico[GetPVarInt(playerid,"Homew")]);
  				  	DestroyDynamic3DTextLabel(thbuy[GetPVarInt(playerid,"Homew")]);
   				 	buyhome[GetPVarInt(playerid,"Homew")] = CreateDynamicPickup(1273, 23 , HouseInfo[GetPVarInt(playerid,"Homew")][hEnt][0],HouseInfo[GetPVarInt(playerid,"Homew")][hEnt][1],HouseInfo[GetPVarInt(playerid,"Homew")][hEnt][2] ,0,-1,-1);
    				buyico[GetPVarInt(playerid,"Homew")] = CreateDynamicMapIcon(HouseInfo[GetPVarInt(playerid,"Homew")][hEnt][0],HouseInfo[GetPVarInt(playerid,"Homew")][hEnt][1],HouseInfo[GetPVarInt(playerid,"Homew")][hEnt][2],31, 0x1E90FFAA,0,-1,-1);
    				format(ses,sizeof(ses),"{00cc33}Дом продается !\n{0066cc}Стоимость - {00cc33}%i\n{0066cc}Уровень - {00cc33}%i\n{0066cc}Дом № {00cc33}%i",HouseInfo[GetPVarInt(playerid,"Homew")][hPrice],HouseInfo[GetPVarInt(playerid,"Homew")][hLevel],GetPVarInt(playerid,"Homew"));
    				thbuy[GetPVarInt(playerid,"Homew")] = CreateDynamic3DTextLabel(ses,0x1E90FFAA,HouseInfo[GetPVarInt(playerid,"Homew")][hEnt][0],HouseInfo[GetPVarInt(playerid,"Homew")][hEnt][1],HouseInfo[GetPVarInt(playerid,"Homew")][hEnt][2]+0.6,100,INVALID_PLAYER_ID,INVALID_VEHICLE_ID,0,0,-1,-1);
				}
				case 1:
				{
 				   	DestroyDynamicPickup(buyhome[GetPVarInt(playerid,"Homew")]);
					DestroyDynamicMapIcon(buyico[GetPVarInt(playerid,"Homew")]);
					DestroyDynamic3DTextLabel(thbuy[GetPVarInt(playerid,"Homew")]);
					format(ses,sizeof(ses),"{993300}Владец - {006699}%s\n{993300}{0066cc}Дом № {006699}%i",Ownerh(GetPVarInt(playerid,"Homew")),GetPVarInt(playerid,"Homew"));
  	      			buyhome[GetPVarInt(playerid,"Homew")] = CreateDynamicPickup(1318, 23 , HouseInfo[GetPVarInt(playerid,"Homew")][hEnt][0],HouseInfo[GetPVarInt(playerid,"Homew")][hEnt][1],HouseInfo[GetPVarInt(playerid,"Homew")][hEnt][2] ,0,-1,-1);
  	      			buyico[GetPVarInt(playerid,"Homew")] = CreateDynamicMapIcon(HouseInfo[GetPVarInt(playerid,"Homew")][hEnt][0],HouseInfo[GetPVarInt(playerid,"Homew")][hEnt][1],HouseInfo[GetPVarInt(playerid,"Homew")][hEnt][2],32, 0x1E90FFAA,0,-1,-1);
  	      			thbuy[GetPVarInt(playerid,"Homew")] = CreateDynamic3DTextLabel(ses,0x1E90FFAA,HouseInfo[GetPVarInt(playerid,"Homew")][hEnt][0],HouseInfo[GetPVarInt(playerid,"Homew")][hEnt][1],HouseInfo[GetPVarInt(playerid,"Homew")][hEnt][2]+0.6,100,INVALID_PLAYER_ID,INVALID_VEHICLE_ID,0,0,-1,-1);
				}
			}
			ShowHEDialog(playerid,GetPVarInt(playerid,"Homew"));
		}
		return 1;
	}
	if(response == EDIT_RESPONSE_CANCEL)
	{
	    if(objectid == GetPVarInt(playerid,"ObjectH"))
		{
			DestroyObject(GetPVarInt(playerid,"ObjectH"));
			SetPVarInt(playerid,"ObjectH",0);
			ShowHDialog(playerid);
		}
		else if(objectid == GetPVarInt(playerid,"ObjectHE"))
		{
		    DestroyObject(GetPVarInt(playerid,"ObjectHE"));
			SetPVarInt(playerid,"ObjectHE",0);
			ShowHEDialog(playerid,GetPVarInt(playerid,"Homew"));
		}
		return 1;
	}
	return 1;
}


public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid)
{
	if(cartp[vehicleid] == 2)
	{
		for(new i=0;i<allcars;i++)
		{
		    if(carsb[i]==vehicleid)
		    {
		        GetVehiclePos(vehicleid,CarsInfo[i][cPos][0],CarsInfo[i][cPos][1],CarsInfo[i][cPos][2]);
		        GetVehicleZAngle(vehicleid,CarsInfo[i][cPos][3]);
		    }
		}
	    return 1;
	}
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
	format(ses,sizeof(ses),"%i - %i",GetVehicleComponentType(componentid),componentid);
	SendClientMessage(playerid,COLOR_RED,ses);
	if(cartp[vehicleid] == 2)
	{
	    for(new i=0;i < MAX_CARS;i++)
	    {
	        if(carsb[i] != vehicleid) continue;
	        else
	        {

				CarsInfo[i][cComp][GetVehicleComponentType(componentid)] = componentid;
				format(ses,sizeof(ses),"В слот %i , поставили %i",GetVehicleComponentType(componentid),componentid);
				SendClientMessage(playerid,COLOR_BLUE,ses);
				break;
			}
		}
		return 1;
	}
	return 1;
}

public OnVehiclePaintjob(playerid, vehicleid, paintjobid)
{
	if(cartp[vehicleid] == 2)
	{
	    for(new i=0;i < MAX_CARS;i++)
	    {
	        if(carsb[i] != vehicleid) continue;
	        else
	        {
				CarsInfo[i][cColors][2] = paintjobid;
				break;
	        }
		}
	}
	return 1;
}

public OnVehicleRespray(playerid, vehicleid, color1, color2)
{
    if(cartp[vehicleid] == 2)
	{
	    for(new i=0;i < MAX_CARS;i++)
	    {
	        if(carsb[i] != vehicleid) continue;
	        else
	        {
				CarsInfo[i][cColors][0] = color1;
				CarsInfo[i][cColors][1] = color2;
				break;
	        }
		}
	}
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
	if(newkeys == 1024)
	{
		if(IsPlayerInRangeOfPoint(playerid,2,1482.30701, -1764.46826, 15.27360))
		{
			SetPlayerPos(playerid,384.808624,173.804992,1008.382812);
			SetPlayerInterior(playerid,3);
			return 1;
		}
		if(IsPlayerInRangeOfPoint(playerid,2,384.808624,173.804992,1008.382812) && GetPlayerInterior(playerid) == 3)
		{
		    SetPlayerPos(playerid,1482.5952,-1772.2556,20.7958);
			SetPlayerInterior(playerid,0);
			return 1;
		}
		for(new i =0;i<allhouse;i++)
  		{
  		    if(HouseInfo[i][hBuy] < 1) continue;
   			if(IsPlayerInRangeOfPoint(playerid,1,HouseInfo[i][hExt][0],HouseInfo[i][hExt][1],HouseInfo[i][hExt][2]) && GetPlayerVirtualWorld(playerid) == i)
   			{
    			SetPlayerPos(playerid,HouseInfo[i][hEnt][0],HouseInfo[i][hEnt][1],HouseInfo[i][hEnt][2]);
    			SetPlayerVirtualWorld(playerid,0);
    			SetPlayerInterior(playerid,0);
    			return 1;
   			}
   			if(IsPlayerInRangeOfPoint(playerid,1,HouseInfo[i][hEnt][0],HouseInfo[i][hEnt][1],HouseInfo[i][hEnt][2]) && HouseInfo[i][hBuy] == 1)
   			{
   			    if(HouseInfo[i][hLock] == 1) {SendClientMessage(playerid,-1,COL_RED"[Ошибка]"COL_WHITE" Дверь заперта"); return 1;}
    			SetPlayerPos(playerid,HouseInfo[i][hExt][0],HouseInfo[i][hExt][1],HouseInfo[i][hExt][2]);
			    SetPlayerInterior(playerid,HouseInfo[i][hInt]);
			    SetPlayerVirtualWorld(playerid,i);
			    return 1;
   			}
  		}
	}
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
	return 1;
}

public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
	return 1;
}

public OnPlayerPickUpDynamicPickup(playerid, pickupid)
{
	for(new i=0;i<allhouse;i++)
	{
	    if(buyhome[i] == pickupid)
	    {
	        if(gettime() < GetPVarInt(playerid, "pickupdialogtime")) return 1;
	        SetPVarInt(playerid, "pickupdialogtime", gettime() + 3);
	        SetPVarInt(playerid,"Homew",i);
	        if(HouseInfo[i][hBuy] == 0)
	        {
				format(ses,sizeof(ses),"{00cc33}Дом продается !\n{0066cc}Стоимость - {00cc33}%i\n{0066cc}Дом № {00cc33}%i\nПодтверждая данную фукцию с вас будет снята плата {00cc33}%i и будет приобрет дом",HouseInfo[i][hPrice],i,HouseInfo[i][hPrice]);
				Dialog_Show(playerid, HouseBuy, DIALOG_STYLE_MSGBOX,"Сервис недвижимости",ses,"Купить","Отмена");
			}
			/*else
			{
					if(strcmp(Name(playerid),Ownerh(i)) != 0)
					{
						if(HouseInfo[i][hLock] == 1)
					    {
			        		format(ses,256,"{993300}Владец - {006699}%s\n{993300}{0066cc}Дом № {006699}%i\nДверь закрыта , но вы можете постучать",Ownerh(i),i);
			        		ShowPlayerDialog(playerid,6,0,"Дом",ses,"Постучаться","Отмена");
						}
			        }
			        else
			        {
			            format(ses,256,"{993300}Вы являетесь владельцем данного дома {0066cc}Дом № {006699}%i \n Что желаете сделать с дверю ?",i);
			        	ShowPlayerDialog(playerid,5,0,"Дом",ses,"Дверь","Отмена");
			        }
			}*/
		}
	}
	return 1;
}
Dialog:HouseBuy(playerid, response, listitem, inputtext[])
{
    if(!response) return 1;
    if(Moneys(playerid) >= HouseInfo[GetPVarInt(playerid,"Homew")][hPrice])
	{
 		strmid(Ownerh(GetPVarInt(playerid,"Homew")),Name(playerid),0,24,24);
		Money(playerid,-HouseInfo[GetPVarInt(playerid,"Homew")][hPrice]);
		HouseInfo[GetPVarInt(playerid,"Homew")][hBuy] = 1;
		DestroyDynamicPickup(buyhome[GetPVarInt(playerid,"Homew")]);
		DestroyDynamicMapIcon(buyico[GetPVarInt(playerid,"Homew")]);
		buyhome[GetPVarInt(playerid,"Homew")] = CreateDynamicPickup(1318, 23 , HouseInfo[GetPVarInt(playerid,"Homew")][hEnt][0],HouseInfo[GetPVarInt(playerid,"Homew")][hEnt][1],HouseInfo[GetPVarInt(playerid,"Homew")][hEnt][2] ,0,-1,-1);
		buyico[GetPVarInt(playerid,"Homew")] = CreateDynamicMapIcon(HouseInfo[GetPVarInt(playerid,"Homew")][hEnt][0],HouseInfo[GetPVarInt(playerid,"Homew")][hEnt][1],HouseInfo[GetPVarInt(playerid,"Homew")][hEnt][2],32, 0x1E90FFAA,0,-1,-1);
		format(ses,256,"{993300}Владец - {006699}%s\n{993300}{0066cc}Дом № {006699}%i",Ownerh(GetPVarInt(playerid,"Homew")),GetPVarInt(playerid,"Homew"));
		UpdateDynamic3DTextLabelText(thbuy[GetPVarInt(playerid,"Homew")],0x1E90FFAA,ses);
        new Float:p[3],Float:pp[3];
		new Float:dist = 5.0;
		GetPlayerCameraFrontVector(playerid,p[0],p[1],p[2]);
		GetPlayerCameraPos(playerid,pp[0],pp[1],pp[2]);
        
		InterpolateCameraPos(playerid,pp[0]-p[0],pp[1]-p[1],pp[2]-p[2]+1,pp[0]-dist*p[0],pp[1]-dist*p[1],pp[2]-dist*p[2]+4,7000,CAMERA_MOVE);
		InterpolateCameraLookAt(playerid,HouseInfo[GetPVarInt(playerid,"Homew")][hEnt][0],HouseInfo[GetPVarInt(playerid,"Homew")][hEnt][1],HouseInfo[GetPVarInt(playerid,"Homew")][hEnt][2]+1,HouseInfo[GetPVarInt(playerid,"Homew")][hEnt][0],HouseInfo[GetPVarInt(playerid,"Homew")][hEnt][1],HouseInfo[GetPVarInt(playerid,"Homew")][hEnt][2]+3,7000,CAMERA_MOVE);
		SetTimerEx("Pokaz", 8000, false,"i", playerid);
		TogglePlayerControllable(playerid,0);
		PlayerPlaySound(playerid,31204 , 0.0, 0.0, 10.0);
		format(ses,sizeof(ses),"~g~%s \n ~y~Buy a house \n for %i $",Name(playerid),HouseInfo[GetPVarInt(playerid,"Homew")][hPrice]);
		GameTextForPlayer(playerid, ses, 6000, 1);
		//GameTextForPlayer(playerid, "House was ~g~buy", 2000, 0);
		return 1;
	}
	else return SendClientMessage(playerid,-1,"Агенство недвижимости: Недостаточно денег");
    //return 1;
}
public PlayerCheck(playerid)
{
    if(playerid != INVALID_PLAYER_ID)
	{
		InterpolateCameraPos(playerid,1421.3472,-1725.2466,43.5469,1521.0026,-1720.8508,43.5469,50000,CAMERA_MOVE);
		InterpolateCameraLookAt(playerid,1521.0026,-1720.8508,16.5469,1480.8225,-1757.8739,17.5313,1000,CAMERA_MOVE);
		PlayerPlaySound(playerid,2020,0.0, 0.0, 10.0);
		new rows, fields;
		cache_get_data(rows, fields, pl);
		if(rows)
		{
			cache_get_row(0,2,Pass(playerid),pl);
			cache_get_row(0,4,PlayerInfo[playerid][pMail],pl);
			SetPVarInt(playerid,"AutorD",0);
			TextDrawC(playerid,0);
		}
		else
		{
            TextDrawC(playerid,1);
            SetPVarInt(playerid,"AutorD",2);
		}
	}
	return 1;
}


public OnPlayerClickPlayerTextDraw(playerid, PlayerText:playertextid)
{
    if(playertextid == Textbc[playerid][4])
    {
        if(GetPVarInt(playerid,"Pla") <= 0) return 1;
		SetPVarInt(playerid,"Pla",GetPVarInt(playerid,"Pla")-1);
		DestroyVehicle(GetPVarInt(playerid,"Homew"));
		SetPVarInt(playerid,"Homew",CreateVehicle(cafb[GetPVarInt(playerid,"Pla")][0],-2955.4177,2581.3289,119.8971,224.7385,random(255),random(255),0));
		SetVehicleVirtualWorld(GetPVarInt(playerid,"Homew"),playerid);
		format(ses,sizeof(ses),"Name: ~g~%s",NameCar[GetVehicleModel(GetPVarInt(playerid,"Homew"))-400]);
		PlayerTextDrawSetString(playerid,Textbc[playerid][1],ses);
		SetPVarInt(playerid,"HPrice",cafb[GetPVarInt(playerid,"Pla")][1]);
		format(ses,sizeof(ses),"Price: ~g~%i$",GetPVarInt(playerid,"HPrice"));
		PlayerTextDrawSetString(playerid,Textbc[playerid][2],ses);
		PlayerPlaySound(playerid,1054,0.0, 0.0, 10.0);
		return 1;
	}
	else if(playertextid == Textbc[playerid][5])
    {
        if(GetPVarInt(playerid,"Pla") > (sizeof(cafb)-2)) return 1;
		SetPVarInt(playerid,"Pla",GetPVarInt(playerid,"Pla")+1);
		DestroyVehicle(GetPVarInt(playerid,"Homew"));
		SetPVarInt(playerid,"Homew",CreateVehicle(cafb[GetPVarInt(playerid,"Pla")][0],-2955.4177,2581.3289,119.8971,224.7385,random(255),random(255),0));
		SetVehicleVirtualWorld(GetPVarInt(playerid,"Homew"),playerid);
		format(ses,sizeof(ses),"Name: ~g~%s",NameCar[GetVehicleModel(GetPVarInt(playerid,"Homew"))-400]);
		PlayerTextDrawSetString(playerid,Textbc[playerid][1],ses);
		SetPVarInt(playerid,"HPrice",cafb[GetPVarInt(playerid,"Pla")][1]);
		format(ses,sizeof(ses),"Price: ~g~%i$",GetPVarInt(playerid,"HPrice"));
		PlayerTextDrawSetString(playerid,Textbc[playerid][2],ses);
		PlayerPlaySound(playerid,1055,0.0, 0.0, 10.0);
		return 1;
	}
	else if(playertextid == Textbc[playerid][3])
    {
        if(PlayerInfo[playerid][pMoney] < GetPVarInt(playerid,"HPrice")) return SendClientMessage(playerid,COLOR_RED,"No money - no ta4ki");
        SetVehicleVirtualWorld(GetPVarInt(playerid,"Homew"),0);
        TogglePlayerControllable(playerid,1);
   		TogglePlayerSpectating(playerid, 0);
    	SetCameraBehindPlayer(playerid);
    	SetPlayerVirtualWorld(playerid,0);
    	SetVehiclePos(GetPVarInt(playerid,"Homew"),1358.4294,-1751.1085,13.0529);
    	for(new i=0;i<6;i++) PlayerTextDrawDestroy(playerid,Textbc[playerid][i]);
    	CancelSelectTextDraw(playerid);
    	cartp[GetPVarInt(playerid,"Homew")] = 2;
		carsb[allcars] = GetPVarInt(playerid,"Homew");
		CarsInfo[allcars][cModel] = GetVehicleModel(GetPVarInt(playerid,"Homew"));
    	strmid(Ownerc(allcars),Name(playerid),0,24,24);
    	CarsInfo[allcars][cBuy] = 1;
    	CarsInfo[allcars][cColors][0] = random(255);
    	CarsInfo[allcars][cColors][1] = random(255);
		format(ses,sizeof(ses),"{993300}Авто куплено !\n{993300}Владец - {006699}%s\n{993300}Авто № {006699}%i",CarsInfo[allcars][cOwner],allcars);
 	    tcbuy[allcars] = CreateDynamic3DTextLabel(ses,0xFFA500AA,0,0,0.6,100,INVALID_PLAYER_ID,carsb[allcars]);
 	    format(sesql, sizeof(sesql), "INSERT INTO `cars` (Owner,Model,Buy,ID) VALUES ('%s','%i','%i','%i')",Ownerc(allcars),GetVehicleModel(GetPVarInt(playerid,"Homew")),CarsInfo[allcars][cBuy],allcars);
		mysql_function_query(pl, sesql, false, "SendQuery", "");
		printf("Pb allcars - %d",allcars);
 	    allcars++;
 	    printf("Pb allcars - %d",allcars);
 	    PlayerPlaySound(playerid,1057,0.0, 0.0, 10.0);
        return 1;
	}
    else if(playertextid == Textdrawl[playerid][3])
    {
        PlayerPlaySound(playerid,1083,0.0, 0.0, 10.0);
    	Dialog_Show(playerid, LogEm, DIALOG_STYLE_INPUT, "Ввод E-Mail", "Здравствуйте , просим вас о вводе вашего E-Mail для входа на сервер\nТакже напоминаем что на сервере осуществлена проверка , так что вводите коректно", "Принять", "Отмена");
    	return 1;
    }
    else if(PlayerText:playertextid == Textdrawl[playerid][4])
    {
        PlayerPlaySound(playerid,1083,0.0, 0.0, 10.0);
   		Dialog_Show(playerid, LogPass, DIALOG_STYLE_INPUT, "Ввод пароля", "Здравствуйте , просим вас о вводе вашего пароля для входа на сервер\nТакже напоминаем что на сервере осуществлена проверка , так что вводите коректно", "Принять", "Отмена");
   		return 1;
	}
	else if(PlayerText:playertextid == PlayerText:Textdrawl[playerid][1])
    {
        PlayerPlaySound(playerid,1056,0.0, 0.0, 10.0);
		new temp[65];
		GetPVarString(playerid,"Mailq",temp,sizeof(temp));
		
		if(!strlen(temp)) {SendClientMessage(playerid,COLOR_RED,"Ошибка , проверьте данные"); return 1;}
		if(strcmp(temp,PlayerInfo[playerid][pMail])) { PlayerTextDrawSetString(playerid,Textdrawl[playerid][3],"E-Mail: ~g~Error"); return 1;}
		GetPVarString(playerid,"Passq",temp,sizeof(temp));
		if(!strlen(temp)) {SendClientMessage(playerid,COLOR_RED,"Ошибка , проверьте данные"); return 1;}
		SHA256_PassHash(temp, salt, temp, 65);
		if(strcmp(temp,Pass(playerid)))
		{
		PlayerTextDrawSetString(playerid,Textdrawl[playerid][4],"Pass: ~r~Error"); return 1;}
		format(sesql, sizeof(sesql), "SELECT * FROM `players` WHERE `Name`='%s' LIMIT 1", Name(playerid));
 		mysql_function_query(pl, sesql, true, "LoadAkk", "d", playerid);
 		CancelSelectTextDraw(playerid);
 		CancelSelectTextDraw(playerid);
 		for(new i=0;i<6;i++) {PlayerTextDrawHide(playerid,Textdrawl[playerid][i]); PlayerTextDrawDestroy(playerid,Textdrawl[playerid][i]);}
 		return 1;
	}
	else if(playertextid == Textdrawr[playerid][3])
    {
        PlayerPlaySound(playerid,1083,0.0, 0.0, 10.0);
        Dialog_Show(playerid, RegPass, DIALOG_STYLE_INPUT, "Ввод пароля", "Здравствуйте , просим вас о вводе вашего пароля для регистрации на сервере\nТакже напоминаем что на сервере осуществлена проверка , так что вводите коректно", "Принять", "Отмена");
        return 1;
        //Pass
    }
    else if(playertextid == Textdrawr[playerid][4])
    {
        PlayerPlaySound(playerid,1083,0.0, 0.0, 10.0);
        Dialog_Show(playerid, RegMail, DIALOG_STYLE_INPUT, "Ввод E-Mail", "Здравствуйте , просим вас о вводе вашего E-Mail для регистрации на сервере\nТакже напоминаем что на сервере осуществлена проверка , так что вводите коректно", "Принять", "Отмена");
        return 1;
        //Mail
    }
    else if(playertextid == Textdrawr[playerid][5])
    {
        PlayerPlaySound(playerid,1083,0.0, 0.0, 10.0);
        Dialog_Show(playerid, RegDate, DIALOG_STYLE_INPUT, "Ввод даты", "Здравствуйте , просим вас о вводе вашей даты для регистрации на сервере\nТакже напоминаем что на сервере осуществлена проверка , так что вводите коректно (**/**/****)", "Принять", "Отмена");
        return 1;
        //Date
    }
    else if(playertextid == Textdrawr[playerid][6])
    {
        PlayerPlaySound(playerid,1083,0.0, 0.0, 10.0);
        Dialog_Show(playerid, RegCity, DIALOG_STYLE_LIST, "Выбор города", "Los Santos\nSan Fierno\nLas Vegas", "Выбрать", "Отмена");
        return 1;
        //City
    }
    else if(playertextid == Textdrawr[playerid][7])
    {
        //Dialog_Show(playerid, RegMale, DIALOG_STYLE_MSGBOX, "Выбор стати", "Здравствуйте , просим о выборе вашей стати", "Мужчина", "Женщина");
		if(PlayerInfo[playerid][pMale] == 1)
		{
		    PlayerInfo[playerid][pMale] = 2;
			PlayerTextDrawSetString(playerid,Textdrawr[playerid][7],"Woman");
			PlayerInfo[playerid][pSkin] = rskin[GetPVarInt(playerid,"Pla")][1];
			PlayerTextDrawSetPreviewModel(playerid, Textdrawr[playerid][8], rskin[GetPVarInt(playerid,"Pla")][1]);
			PlayerTextDrawShow(playerid,Textdrawr[playerid][8]);
			return 1;
		}
		PlayerInfo[playerid][pMale] = 1;
		PlayerTextDrawSetString(playerid,Textdrawr[playerid][7],"Man");
		PlayerInfo[playerid][pSkin] = rskin[GetPVarInt(playerid,"Pla")][0];
		PlayerTextDrawSetPreviewModel(playerid, Textdrawr[playerid][8], rskin[GetPVarInt(playerid,"Pla")][0]);
		PlayerTextDrawShow(playerid,Textdrawr[playerid][8]);
 		return 1;
        //Male
    }
    else if(playertextid == Textdrawr[playerid][9])
    {
        PlayerPlaySound(playerid,1055,0.0, 0.0, 10.0);
        if(GetPVarInt(playerid,"Pla") < 1) return 0;
        if(PlayerInfo[playerid][pMale] == 1)
        {
			SetPVarInt(playerid,"Pla",GetPVarInt(playerid,"Pla")-1);
			PlayerInfo[playerid][pSkin] = rskin[GetPVarInt(playerid,"Pla")][0];
			PlayerTextDrawSetPreviewModel(playerid, Textdrawr[playerid][8], rskin[GetPVarInt(playerid,"Pla")][0]);
			PlayerTextDrawShow(playerid,Textdrawr[playerid][8]);
        }
        PlayerPlaySound(playerid,1055,0.0, 0.0, 10.0);
        if(PlayerInfo[playerid][pMale] == 2)
        {
			SetPVarInt(playerid,"Pla",GetPVarInt(playerid,"Pla")-1);
			PlayerInfo[playerid][pSkin] = rskin[GetPVarInt(playerid,"Pla")][1];
			PlayerTextDrawSetPreviewModel(playerid, Textdrawr[playerid][8], rskin[GetPVarInt(playerid,"Pla")][1]);
			PlayerTextDrawShow(playerid,Textdrawr[playerid][8]);
        }
		return 1;
        //<
    }
    else if(playertextid == Textdrawr[playerid][10])
    {
        PlayerPlaySound(playerid,1054,0.0, 0.0, 10.0);
		if(GetPVarInt(playerid,"Pla") > 4) return 1;
        if(PlayerInfo[playerid][pMale] == 1)
		{
			SetPVarInt(playerid,"Pla",GetPVarInt(playerid,"Pla")+1);
			PlayerInfo[playerid][pSkin] = rskin[GetPVarInt(playerid,"Pla")][0];
			PlayerTextDrawSetPreviewModel(playerid, Textdrawr[playerid][8], rskin[GetPVarInt(playerid,"Pla")][0]);
			PlayerTextDrawShow(playerid,Textdrawr[playerid][8]);
		}
        if(PlayerInfo[playerid][pMale] == 2)
		{
			SetPVarInt(playerid,"Pla",GetPVarInt(playerid,"Pla")+1);
			PlayerInfo[playerid][pSkin] = rskin[GetPVarInt(playerid,"Pla")][1];
			PlayerTextDrawSetPreviewModel(playerid, Textdrawr[playerid][8], rskin[GetPVarInt(playerid,"Pla")][1]);
			PlayerTextDrawShow(playerid,Textdrawr[playerid][8]);
		}
		return 1;
        //>
    }
    else if(playertextid == Textdrawr[playerid][11])
    {
        PlayerPlaySound(playerid,1083,0.0, 0.0, 10.0);
        if(!strlen(Pass(playerid))) return SendClientMessage(playerid,-1,COL_RED"[Ошибка]"COL_WHITE" Требуется пароль");
        if(!strlen(PlayerInfo[playerid][pMail])) return SendClientMessage(playerid,-1,COL_RED"[Ошибка]"COL_WHITE" Введи адрес почты");
		if(!strlen(PlayerInfo[playerid][pDate])) return SendClientMessage(playerid,-1,COL_RED"[Ошибка]"COL_WHITE" Укажи дату");
		if(!PlayerInfo[playerid][pMale]) return SendClientMessage(playerid,-1,COL_RED"[Ошибка]"COL_WHITE" Нету стати");
		if(!PlayerInfo[playerid][pSkin]) return SendClientMessage(playerid,-1,COL_RED"[Ошибка]"COL_WHITE" Требуется выбрать внешность персонажа");
		CancelSelectTextDraw(playerid);
		SendClientMessage(playerid,-1,"11");
		for(new i=0;i<12;i++) {PlayerTextDrawHide(playerid,Textdrawr[playerid][i]);PlayerTextDrawDestroy(playerid,Textdrawr[playerid][i]);}
		CancelSelectTextDraw(playerid);
		CreateAccount(playerid);
		return 1;
        //Register
    }
    return 1;
}
public OnPlayerClickTextDraw(playerid, Text:clickedid)
{
    if(clickedid == Text:(INVALID_TEXT_DRAW ))
	{
	    if(!GetPVarInt(playerid,"Login"))
	    {
	        SelectTextDraw(playerid, 0xFFC0CBAA);
	        /*if(GetPVarInt(playerid,"AutorD")) return 1;
			SendClientMessage(playerid, COLOR_GREEN, "Диалоговая система логина");
			//
			CancelSelectTextDraw(playerid);
			if(GetPVarInt(playerid,"AutorD") == 0) for(new i=0;i<6;i++) {PlayerTextDrawHide(playerid,Textdrawl[playerid][i]); PlayerTextDrawDestroy(playerid,Textdrawl[playerid][i]);}
			if(GetPVarInt(playerid,"AutorD") == 2) for(new i=0;i<12;i++) {PlayerTextDrawHide(playerid,Textdrawr[playerid][i]); PlayerTextDrawDestroy(playerid,Textdrawr[playerid][i]);}
			SetPVarInt(playerid,"AutorD",1);
			Dialog_Show(playerid, Logak, DIALOG_STYLE_TABLIST, "Авторизация", "Маил\t-\t[Введите емеил]\nПароль\t-\t[Введите пароль]\n-\tВойти\t-", "Next", "");*/
			return 1;
		}
		if(GetPVarInt(playerid,"Pbcar"))
	    {
	        TogglePlayerControllable(playerid,1);
	    	TogglePlayerSpectating(playerid, 0);
	    	SetCameraBehindPlayer(playerid);
	    	SetPlayerVirtualWorld(playerid,0);
	    	SpawnPlayer(playerid);
	        CancelSelectTextDraw(playerid);
	        DestroyVehicle(GetPVarInt(playerid,"Homew"));
	        for(new i=0;i<6;i++) PlayerTextDrawDestroy(playerid,Textbc[playerid][i]);
	        SetPVarInt(playerid,"Pbcar",0);
	        return 1;
	    }
		return 1;
	}
    return 1;
}
Dialog:Logak(playerid, response, listitem, inputtext[])
{
	if(!response) return Kick(playerid);
    PlayerPlaySound(playerid,1083,0.0, 0.0, 10.0);
   	switch(listitem)
 	{
 		case 0:Dialog_Show(playerid, LogEm, DIALOG_STYLE_INPUT, "Ввод E-Mail", "Здравствуйте , просим вас о вводе вашего E-Mail для входа на сервер\nТакже напоминаем что на сервере осуществлена проверка , так что вводите коректно", "Принять", "Отмена");
		case 1:Dialog_Show(playerid, LogPass, DIALOG_STYLE_INPUT, "Ввод пароля", "Здравствуйте , просим вас о вводе вашего пароля для входа на сервер\nТакже напоминаем что на сервере осуществлена проверка , так что вводите коректно", "Принять", "Отмена");
		case 2:
		{
			new temp[36];
		    GetPVarString(playerid,"Mailq",temp,sizeof(temp));
			if(!strlen(temp)) {SendClientMessage(playerid,COLOR_RED,"Ошибка , проверьте данные"); return 1;}
			if(strcmp(temp,PlayerInfo[playerid][pMail])) { SendClientMessage(playerid,COLOR_RED,"Ошибка , проверьте маил"); return 1;}
			GetPVarString(playerid,"Passq",temp,sizeof(temp));
			if(!strlen(temp)) {SendClientMessage(playerid,COLOR_RED,"Ошибка , проверьте данные"); return 1;}
			if(strcmp(temp,Pass(playerid))) { SendClientMessage(playerid,COLOR_RED,"Ошибка , проверьте пароль"); return 1;}
			format(sesql, sizeof(sesql), "SELECT * FROM `players` WHERE `Name`='%s' LIMIT 1", Name(playerid));
 			mysql_function_query(pl, sesql, true, "LoadAkk", "d", playerid);
		}
	}
	return 1;
}
/*Dialog:RegMale(playerid, response, listitem, inputtext[])
{
    if(!response)
	{
		PlayerInfo[playerid][pMale] = 2;
		PlayerTextDrawSetString(playerid,Textdrawr[playerid][7],"Woman");
		return 1;
	}
	PlayerInfo[playerid][pMale] = 1;
	PlayerTextDrawSetString(playerid,Textdrawr[playerid][7],"Man");
    return 1;
}*/
Dialog:RegCity(playerid, response, listitem, inputtext[])
{
    if(!response) return 1;
	switch(listitem)
	{
		case 0: {PlayerInfo[playerid][pFrom] = 0; format(ses,sizeof(ses),"City: ~p~Los Santos",inputtext);}
		case 1: {PlayerInfo[playerid][pFrom] = 1; format(ses,sizeof(ses),"City: ~p~San Fierno",inputtext);}
		case 2: {PlayerInfo[playerid][pFrom] = 2; format(ses,sizeof(ses),"City: ~p~Las Venturas",inputtext);}
	}
	PlayerTextDrawSetString(playerid,Textdrawr[playerid][6],ses);
	return 1;
}
Dialog:RegDate(playerid, response, listitem, inputtext[])
{
    if(!response) return 1;
    if(!IsValidDate(inputtext)) {SendClientMessage(playerid,-1,COL_RED"[Ошибка]"COL_WHITE" Обнаружены запрещенные значения! "COL_APELS"(Исп.: --/--/----)");return 1;}
    strmid(PlayerInfo[playerid][pDate],inputtext,0,24,24);
 	format(ses,sizeof(ses),"Date: ~y~%s",inputtext);
 	PlayerTextDrawSetString(playerid,Textdrawr[playerid][5],ses);
 	return 1;
}
Dialog:RegPass(playerid, response, listitem, inputtext[])
{
    if(!response) return 1;
    if(!IsValidPass(inputtext)) {SendClientMessage(playerid,-1,COL_RED"[Ошибка]"COL_WHITE" В пароле могут быть только символы латинского алфавита и цифры");return 1;}
 	strmid(Pass(playerid),inputtext,0,24,24);
	/*new ns = strlen(inputtext);
	new seo[24];
	for(new i=0;i<ns;i++)
	{
		seo[i] = '&';
	}*/
 	format(ses,sizeof(ses),"Pass: ~r~%s",inputtext);
 	PlayerTextDrawSetString(playerid,Textdrawr[playerid][3],ses);
 	return 1;
}
Dialog:RegMail(playerid, response, listitem, inputtext[])
{
    if(!response) return 1;
    if(!IsValidEmail(inputtext)) {SendClientMessage(playerid,-1,COL_RED"[Ошибка]"COL_WHITE" В адресе почты обнаружены запрещенные символы "COL_APELS"(Исп.: ------@---.--)");return 1;}
 	strmid(PlayerInfo[playerid][pMail],inputtext,0,24,24);
 	format(ses,sizeof(ses),"E-Mail: ~g~%s",inputtext);
 	PlayerTextDrawSetString(playerid,Textdrawr[playerid][4],ses);
 	return 1;
}
public LoadAkk(playerid)
{
	new rows, fields;
	cache_get_data(rows, fields);
	if(rows)
	{
		Moneys(playerid) = cache_get_row_int(0,3,pl);
		cache_get_row(0,4,PlayerInfo[playerid][pMail],pl);
		Level(playerid) = cache_get_row_int(0,5,pl);
		PlayerInfo[playerid][pMale] = cache_get_row_int(0,6,pl);
		PlayerInfo[playerid][pSkin] = cache_get_row_int(0,7,pl);
		cache_get_row(0,8,ses,pl);
		sscanf(ses, "fff",PlayerInfo[playerid][pPos][0],PlayerInfo[playerid][pPos][1],PlayerInfo[playerid][pPos][2]);
		cache_get_row(0,9,PlayerInfo[playerid][pDate],pl);
		cache_get_row(0,10,ses,pl);
		sscanf(ses, "ii",PlayerInfo[playerid][pIntW][0],PlayerInfo[playerid][pIntW][1]);
		GivePlayerMoney(playerid,Moneys(playerid));
		SetPlayerScore(playerid,Level(playerid));
		SetPlayerSkin(playerid,PlayerInfo[playerid][pSkin]);
	    TogglePlayerControllable(playerid,1);
	    TogglePlayerSpectating(playerid, 0);
	    SetCameraBehindPlayer(playerid);
	    SetPVarInt(playerid,"Login",1);
	    SetSpawnInfo(playerid,0,PlayerInfo[playerid][pSkin],PlayerInfo[playerid][pPos][0],PlayerInfo[playerid][pPos][1],PlayerInfo[playerid][pPos][2],0,0,0,0,0,0,0);
	    SpawnPlayer(playerid);
	    SetPlayerInterior(playerid,PlayerInfo[playerid][pIntW][0]);
	    SetPlayerVirtualWorld(playerid,PlayerInfo[playerid][pIntW][1]);
		//SetPlayerPos(playerid,PlayerInfo[playerid][pPos][0],PlayerInfo[playerid][pPos][1],PlayerInfo[playerid][pPos][2]);
        return 1;
  	}
  	return 1;
}
stock CreateAccount(playerid)
{
    print(Pass(playerid));
	SHA256_PassHash(Pass(playerid), salt, Pass(playerid),65);
	print(Pass(playerid));
	format(sesql, sizeof(sesql), "INSERT INTO `players` (Name,Pass,Mail) VALUES ('%s','%s','%s')",Name(playerid),Pass(playerid),PlayerInfo[playerid][pMail]);
	mysql_function_query(pl, sesql, false, "SendQuery", "");
	PlayerInfo[playerid][pPos][0] = 1421.3472+random(100);
	PlayerInfo[playerid][pPos][1] = -1725.2466;
	PlayerInfo[playerid][pPos][2] = 14.5469;
	TogglePlayerSpectating(playerid, 0);
	TogglePlayerControllable(playerid,1);
	SetPVarInt(playerid,"Login",1);
	SetSpawnInfo(playerid,0,PlayerInfo[playerid][pSkin],PlayerInfo[playerid][pPos][0],PlayerInfo[playerid][pPos][1],PlayerInfo[playerid][pPos][2],0,0,0,0,0,0,0);
	SpawnPlayer(playerid);
	return 1;
}
stock SavePlayer(playerid)
{
	GetPlayerPos(playerid,PlayerInfo[playerid][pPos][0],PlayerInfo[playerid][pPos][1],PlayerInfo[playerid][pPos][2]);
	PlayerInfo[playerid][pIntW][0] = GetPlayerInterior(playerid);
	PlayerInfo[playerid][pIntW][1] = GetPlayerVirtualWorld(playerid);
	format(sesql,sizeof(sesql),"UPDATE `players` SET ");
	format(ses, sizeof(ses), "Money = '%d' ,", Moneys(playerid));strcat(sesql, ses, sizeof(sesql));
	format(ses, sizeof(ses), "Level = '%d' ,", Level(playerid));strcat(sesql, ses, sizeof(sesql));
	format(ses, sizeof(ses), "Male = '%d' ,", PlayerInfo[playerid][pMale]);strcat(sesql, ses, sizeof(sesql));
	format(ses, sizeof(ses), "Skin = '%d' ,", PlayerInfo[playerid][pSkin]);strcat(sesql, ses, sizeof(sesql));
	format(ses, sizeof(ses), "Date = '%s' ,", PlayerInfo[playerid][pDate]);strcat(sesql, ses, sizeof(sesql));
	format(ses, sizeof(ses), "IntW = '%i %i' ,", PlayerInfo[playerid][pIntW][0] , PlayerInfo[playerid][pIntW][1]);strcat(sesql, ses, sizeof(sesql));
	format(ses, sizeof(ses), "Pos = '%f %f %f' ", PlayerInfo[playerid][pPos][0],PlayerInfo[playerid][pPos][1],PlayerInfo[playerid][pPos][2]);strcat(sesql, ses, sizeof(sesql));
	format(ses, sizeof(ses),"WHERE Name = '%s'",PlayerInfo[playerid][pName]);strcat(sesql,ses,sizeof(sesql));
	mysql_function_query(pl, sesql, false, "SendQuery", "");
	return 1;
}
Dialog:LogEm(playerid, response, listitem, inputtext[])
{
	if(!response)
	{
	    if(GetPVarInt(playerid,"AutorD"))
 		{
 	    	new templ[24];
 	    	format(ses,sizeof(ses),"Маил\t",1);
 	    	GetPVarString(playerid,"Mailq",templ,sizeof(templ));
 	    	strcat(ses,templ,sizeof(ses));
 	    	strcat(ses,"\t}-{\nПароль\t",sizeof(ses));
 	    	GetPVarString(playerid,"Passq",templ,sizeof(templ));
 	    	strcat(ses,templ,sizeof(ses));
 	    	strcat(ses,"\t}-{\n-\tВойти\t-",sizeof(ses));
 	    	SendClientMessage(playerid,COLOR_GREEN,ses);
 	    	Dialog_Show(playerid, Logak, DIALOG_STYLE_TABLIST, "Авторизация", ses , "Next", "");
 	    	return 1;
 		}
		return 1;
	}
	if(!IsValidEmail(inputtext))
	{
		SendClientMessage(playerid,-1,COL_RED"[Ошибка]"COL_WHITE" В адресе почты обнаружены запрещенные символы "COL_APELS"(Исп.: ------@---.--)");
		if(GetPVarInt(playerid,"AutorD"))
 		{
 	    	new templ[24];
 	    	GetPVarString(playerid,"Passq",templ,sizeof(templ));
 	    	format(ses,sizeof(ses),"Маил\t%s\t}-{\nПароль\t%s\t}-{\n-\tВойти\t-","Error",templ);
 	    	Dialog_Show(playerid, Logak, DIALOG_STYLE_TABLIST, "Авторизация", ses , "Next", "");
 	    	return 1;
 		}
		return 1;
	}
 	SetPVarString(playerid,"Mailq",inputtext);
 	if(GetPVarInt(playerid,"AutorD"))
 	{
 	    new templ[24];
 	    GetPVarString(playerid,"Passq",templ,sizeof(templ));
 	    format(ses,sizeof(ses),"Маил\t%s\t}-{\nПароль\t%s\t}-{\n-\tВойти\t-",inputtext,templ);
 	    Dialog_Show(playerid, Logak, DIALOG_STYLE_TABLIST, "Авторизация", ses , "Next", "");
 	    return 1;
 	}
 	format(ses,sizeof(ses),"E-Mail: ~g~%s",inputtext);
 	PlayerTextDrawSetString(playerid,Textdrawl[playerid][3],ses);
 	return 1;
}
Dialog:LogPass(playerid, response, listitem, inputtext[])
{
	if(!response)
	{
	    if(GetPVarInt(playerid,"AutorD"))
 		{
 	    	new templ[24];
            format(ses,sizeof(ses),"Маил\t",1);
 	    	GetPVarString(playerid,"Mailq",templ,sizeof(templ));
 	    	strcat(ses,templ,sizeof(ses));
 	    	strcat(ses,"\t}-{\nПароль\t",sizeof(ses));
 	    	GetPVarString(playerid,"Passq",templ,sizeof(templ));
 	    	strcat(ses,templ,sizeof(ses));
 	    	strcat(ses,"\t}-{\n-\tВойти\t-",sizeof(ses));
 	    	Dialog_Show(playerid, Logak, DIALOG_STYLE_TABLIST, "Авторизация", ses , "Next", "");
 	    	return 1;
 		}
		return 1;
	}
	if(!IsValidPass(inputtext))
	{
		SendClientMessage(playerid,-1,COL_RED"[Ошибка]"COL_WHITE" В пароле могут быть только символы латинского алфавита и цифры");
		if(GetPVarInt(playerid,"AutorD"))
 		{
 	    	new templ[24];
 	    	GetPVarString(playerid,"Mailq",templ,sizeof(templ));
 	    	format(ses,sizeof(ses),"Маил\t%s\t}-{\nПароль\t%s\t}-{\n-\tВойти\t-",templ,"Error");
 	    	Dialog_Show(playerid, Logak, DIALOG_STYLE_TABLIST, "Авторизация", ses , "Next", "");
 	    	return 1;
 		}
		return 1;
	}
 	SetPVarString(playerid,"Passq",inputtext);
 	if(GetPVarInt(playerid,"AutorD"))
 	{
 	    new templ[24];
 	    GetPVarString(playerid,"Mailq",templ,sizeof(templ));
 	    format(ses,sizeof(ses),"Маил\t%s\t}-{\nПароль\t%s\t}-{\n-\tВойти\t-",templ,inputtext);
 	    Dialog_Show(playerid, Logak, DIALOG_STYLE_TABLIST, "Авторизация", ses , "Next", "");
 	    return 1;
 	}
 	format(ses,sizeof(ses),"Pass: ~r~%s",inputtext);
 	PlayerTextDrawSetString(playerid,Textdrawl[playerid][4],ses);
 	return 1;
}
stock ShowHDialog(playerid)
{
	format(ses,sizeof(ses),"Цена дома{00BFFF}[%d]\nУровень дома{00BFFF}[%d]",GetPVarInt(playerid,"HPrice"),GetPVarInt(playerid,"HLevel")); 
	if(GetPVarInt(playerid,"HInt") == 0) strcat(ses,"\nИнтерер дома{00BFFF}[Неустановлено]",sizeof(ses));
	else if(GetPVarInt(playerid,"HInt") == 1) strcat(ses,"\nИнтерер дома{00BFFF}[Маленький]",sizeof(ses));
	else if(GetPVarInt(playerid,"HInt") == 2) strcat(ses,"\nИнтерер дома{00BFFF}[Средний]",sizeof(ses));
	if(GetPVarInt(playerid,"ObjectH") == 0) strcat(ses,"\nУстановить иконку дома{00BFFF}[Неустановлено]",sizeof(ses));
	else if(GetPVarInt(playerid,"ObjectH") != 0) strcat(ses,"\nУстановить иконку дома{00BFFF}[Установлено]",sizeof(ses));
	strcat(ses,"\nПрименить",sizeof(ses));
	Dialog_Show(playerid, HouseAdd, DIALOG_STYLE_LIST, "Настройка нового дома", ses, "Выбор", "Отмена");
	return 1;
}
stock ShowHEDialog(playerid,houseid)
{
	format(ses,sizeof(ses),"Владелец{00BFFF}[%s]\nЦена дома{00BFFF}[%d]\nУровень дома{00BFFF}[%d]",Ownerh(houseid),HouseInfo[houseid][hPrice],HouseInfo[houseid][hLevel]);
	if(HouseInfo[houseid][hInt] == 1) strcat(ses,"\nИнтерер дома{00BFFF}[Маленький]",sizeof(ses));
	else if(HouseInfo[houseid][hInt] == 2) strcat(ses,"\nИнтерер дома{00BFFF}[Средний]",sizeof(ses));
	if(HouseInfo[houseid][hBuy] == 1) strcat(ses,"\nСтатус дома{00BFFF}[Куплен]",sizeof(ses));
	else if(HouseInfo[houseid][hBuy] == 0) strcat(ses,"\nСтатус дома{00BFFF}[Продажа]",sizeof(ses));
	else if(HouseInfo[houseid][hBuy] == -1) strcat(ses,"\nСтатус дома{00BFFF}[Удален]",sizeof(ses));
	strcat(ses,"\nПеренести иконку дома{00BFFF}",sizeof(ses));
	Dialog_Show(playerid, HouseEdit, DIALOG_STYLE_LIST, "Настройка дома", ses, "Выбор", "Отмена");
	return 1;
}
public HouseLoad()
{
    new rows, fields;
	cache_get_data(rows, fields);
	allhouse = rows;
	printf("||==================Load House || ==Всего %i===========||",rows);
	for(new i = 0; i < allhouse; i++)
	{
		HouseInfo[i][hBuy] = cache_get_row_int(i,1,pl);
		cache_get_row(i,2,HouseInfo[i][hOwner],pl);
		cache_get_row(i,3,ses,pl);
		sscanf(ses, "fff",HouseInfo[i][hEnt][0],HouseInfo[i][hEnt][1],HouseInfo[i][hEnt][2]);
		cache_get_row(i,4,ses,pl);
		sscanf(ses, "fff",HouseInfo[i][hExt][0],HouseInfo[i][hExt][1],HouseInfo[i][hExt][2]);
		HouseInfo[i][hInt] = cache_get_row_int(i,5,pl);
		HouseInfo[i][hLock] = cache_get_row_int(i,6,pl);
		HouseInfo[i][hPrice] = cache_get_row_int(i,7,pl);
		HouseInfo[i][hLevel] = cache_get_row_int(i,8,pl);
		cache_get_row(i,9,ses,pl);
		sscanf(ses, "iiiii",HouseInfo[i][hCth][0],HouseInfo[i][hCth][1],HouseInfo[i][hCth][2],HouseInfo[i][hCth][3],HouseInfo[i][hCth][4]);
		HouseInfo[i][hMoney] = cache_get_row_int(i,10,pl);
		if(HouseInfo[i][hBuy] == 0)
  		{
    		format(ses,sizeof(ses),"{00cc33}Дом продается !\n{0066cc}Стоимость - {00cc33}%i\n{0066cc}Уровень - {00cc33}%i\n{0066cc}Дом № {00cc33}%i",HouseInfo[i][hPrice],HouseInfo[i][hLevel],i);
    		thbuy[i] = CreateDynamic3DTextLabel(ses,0x1E90FFAA,HouseInfo[i][hEnt][0],HouseInfo[i][hEnt][1],HouseInfo[i][hEnt][2]+0.6,100,INVALID_PLAYER_ID,INVALID_VEHICLE_ID,0,0,-1,-1);
      	 	buyhome[i] = CreateDynamicPickup(1273, 23 , HouseInfo[i][hEnt][0],HouseInfo[i][hEnt][1],HouseInfo[i][hEnt][2] ,0,-1,-1);
          	buyico[i] = CreateDynamicMapIcon(HouseInfo[i][hEnt][0],HouseInfo[i][hEnt][1],HouseInfo[i][hEnt][2],31, 0x1E90FFAA,0,-1,-1);
       	}
        else if(HouseInfo[i][hBuy] == 1)
	 	{
          	format(ses,sizeof(ses),"{993300}Владец - {006699}%s\n{993300}{0066cc}Дом № {006699}%i",Ownerh(i),i);
          	thbuy[i] = CreateDynamic3DTextLabel(ses,0x1E90FFAA,HouseInfo[i][hEnt][0],HouseInfo[i][hEnt][1],HouseInfo[i][hEnt][2]+0.6,100,INVALID_PLAYER_ID,INVALID_VEHICLE_ID,0,0,-1,-1);
  	      	buyhome[i] = CreateDynamicPickup(1318, 23 , HouseInfo[i][hEnt][0],HouseInfo[i][hEnt][1],HouseInfo[i][hEnt][2] ,0,-1,-1);
  	      	buyico[i] = CreateDynamicMapIcon(HouseInfo[i][hEnt][0],HouseInfo[i][hEnt][1],HouseInfo[i][hEnt][2],32, 0x1E90FFAA,0,-1,-1);
   		}
   		printf("%i %s %i",HouseInfo[i][hBuy],HouseInfo[i][hOwner],i);
	}
	return 1;
}
stock SaveHouse()
{
	for(new houseid=0;houseid < allhouse;houseid++)
	{
		format(sesql,sizeof(sesql),"UPDATE `houses` SET ");
		format(ses, sizeof(ses), "Buy='%d' ,", HouseInfo[houseid][hBuy]);strcat(sesql, ses, sizeof(sesql));
		format(ses, sizeof(ses), "Owner='%s' ,", Ownerh(houseid));strcat(sesql, ses, sizeof(sesql));
		format(ses, sizeof(ses), "Ent='%f %f %f' ,", HouseInfo[houseid][hEnt][0],HouseInfo[houseid][hEnt][1],HouseInfo[houseid][hEnt][2]);strcat(sesql, ses, sizeof(sesql));
		format(ses, sizeof(ses), "Ext='%f %f %f' ,", HouseInfo[houseid][hExt][0],HouseInfo[houseid][hExt][1],HouseInfo[houseid][hExt][2]);strcat(sesql, ses, sizeof(sesql));
		format(ses, sizeof(ses), "Inter='%d' ,", HouseInfo[houseid][hInt]);strcat(sesql, ses, sizeof(sesql));
		format(ses, sizeof(ses), "Locked='%d' ,", HouseInfo[houseid][hLock]);strcat(sesql, ses, sizeof(sesql));
		format(ses, sizeof(ses), "Price='%d' ,", HouseInfo[houseid][hPrice]);strcat(sesql, ses, sizeof(sesql));
		format(ses, sizeof(ses), "Level='%d' ,", HouseInfo[houseid][hLevel]);strcat(sesql, ses, sizeof(sesql));
		format(ses, sizeof(ses), "%i %i %i %i %i",HouseInfo[houseid][hCth][0],HouseInfo[houseid][hCth][1],HouseInfo[houseid][hCth][2],HouseInfo[houseid][hCth][3],HouseInfo[houseid][hCth][4]);
		format(ses, sizeof(ses), "Cth='%s' ,", ses);strcat(sesql, ses, sizeof(sesql));
		format(ses, sizeof(ses), "Money='%d' ", HouseInfo[houseid][hMoney]);strcat(sesql, ses, sizeof(sesql));
		format(ses, sizeof(ses), "WHERE ID = '%d'",houseid);strcat(sesql,ses,sizeof(sesql));
		mysql_function_query(pl, sesql, false, "SendQuery", "");
		print(sesql);
 	}
	return 1;
}
stock CreateHouse(houseid,hprice,hlevel,Float:hx,Float:hy,Float:hz,hint)
{
    if(houseid == -1)
	{
	    houseid = allhouse;
	    format(ses,sizeof(ses)," INSERT INTO `houses` (ID,Buy,Owner) VALUES ('%i','0','None')",allhouse);
		mysql_function_query(pl,ses, false, "SendQuery", "");
		allhouse++;
	}
	switch(hint)
	{
		case 1:
		{
		    HouseInfo[houseid][hExt][0] = 2483.2205;
			HouseInfo[houseid][hExt][1] = -872.1638;
			HouseInfo[houseid][hExt][2] = 2883.3989;
			HouseInfo[houseid][hInt] = 1;
		}
		case 2:
		{
		    HouseInfo[houseid][hExt][0] = 1957.8014;
			HouseInfo[houseid][hExt][1] = -295.3812;
			HouseInfo[houseid][hExt][2] = 4846.5444;
			HouseInfo[houseid][hInt] = 2;
		}
	}
	HouseInfo[houseid][hEnt][0] = hx;
	HouseInfo[houseid][hEnt][1] = hy;
	HouseInfo[houseid][hEnt][2] = hz;
	HouseInfo[houseid][hPrice] = hprice;
	HouseInfo[houseid][hLevel] = hlevel;
	HouseInfo[houseid][hBuy] = 0;
	strmid(Ownerh(houseid),"None",0,24,24);
	format(ses,sizeof(ses),"{00cc33}Дом продается !\n{0066cc}Стоимость - {00cc33}%i\n{0066cc}Уровень - {00cc33}%i\n{0066cc}Дом № {00cc33}%i",HouseInfo[houseid][hPrice],HouseInfo[houseid][hLevel],houseid);
	thbuy[houseid] = CreateDynamic3DTextLabel(ses,0xFFA500AA,HouseInfo[houseid][hEnt][0],HouseInfo[houseid][hEnt][1],HouseInfo[houseid][hEnt][2]+0.6,100,INVALID_PLAYER_ID,INVALID_VEHICLE_ID,1,0,-1,-1);
	buyhome[houseid] = CreateDynamicPickup(1273, 23 , HouseInfo[houseid][hEnt][0],HouseInfo[houseid][hEnt][1],HouseInfo[houseid][hEnt][2] ,0,-1,-1);
	buyico[houseid] = CreateDynamicMapIcon(HouseInfo[houseid][hEnt][0],HouseInfo[houseid][hEnt][1],HouseInfo[houseid][hEnt][2],31, 0x1E90FFAA,0,-1,-1);
	return 1;
}
public CarsLoad()
{
	new carcomp[512];
    new rows, fields;
	cache_get_data(rows, fields);
	allcars = rows;
	printf("||==================Load Cars || ==Всего %i===========||",rows);
	for(new i = 0; i < allcars; i++)
	{
		CarsInfo[i][cBuy] = cache_get_row_int(i,1,pl);
		cache_get_row(i,2,Ownerc(i),pl);
		CarsInfo[i][cModel] = cache_get_row_int(i,3,pl);
		CarsInfo[i][cPrice] = cache_get_row_int(i,4,pl);
		cache_get_row(i,5,ses,pl);
		sscanf(ses,"ffff",CarsInfo[i][cPos][0],CarsInfo[i][cPos][1],CarsInfo[i][cPos][2],CarsInfo[i][cPos][3]);
		cache_get_row(i,6,carcomp,pl);
		sscanf(carcomp, "iiiiiiiiiiiii",
		CarsInfo[i][cComp][0],
		CarsInfo[i][cComp][1],
		CarsInfo[i][cComp][2],
		CarsInfo[i][cComp][3],
		CarsInfo[i][cComp][4],
		CarsInfo[i][cComp][5],
		CarsInfo[i][cComp][6],
		CarsInfo[i][cComp][7],
		CarsInfo[i][cComp][8],
		CarsInfo[i][cComp][9],
		CarsInfo[i][cComp][10],
		CarsInfo[i][cComp][11],
		CarsInfo[i][cComp][12]);
		cache_get_row(i,7,ses,pl);
		sscanf(ses, "iii",
		CarsInfo[i][cColors][0],
		CarsInfo[i][cColors][1],
		CarsInfo[i][cColors][2]);
		printf("%d %s %d",CarsInfo[i][cBuy],Ownerc(i),i);
		if(CarsInfo[i][cBuy] == -1) continue;
		carsb[i] = AddStaticVehicleEx(CarsInfo[i][cModel],CarsInfo[i][cPos][0],CarsInfo[i][cPos][1],CarsInfo[i][cPos][2],CarsInfo[i][cPos][3],CarsInfo[i][cColors][0],CarsInfo[i][cColors][1],1000);
		cartp[carsb[i]]=2;
		switch(CarsInfo[i][cBuy])
		{
			case 0:format(ses,sizeof(ses),"{00cc33}Авто продается !\n{0066cc}Стоимость - {00cc33}%i\n{0066cc}Авто № {00cc33}%i",CarsInfo[i][cPrice],i);
			case 1:format(ses,sizeof(ses),"{993300}Авто куплено !\n{993300}Владец - {006699}%s\n{993300}Авто № {006699}%i",CarsInfo[i][cOwner],i);
		}
		for(new v=0;v<13;v++)
		{
			if(CarsInfo[i][cComp][v] != 0)
			{
				AddVehicleComponent(carsb[i],CarsInfo[i][cComp][v]);
			}
		}
		if(CarsInfo[i][cColors][2] != -1)ChangeVehiclePaintjob(carsb[i],CarsInfo[i][cColors][2]);
 	    tcbuy[i] = CreateDynamic3DTextLabel(ses,0xFFA500AA,0,0,0.6,100,INVALID_PLAYER_ID,carsb[i]);
		//HouseInfo[i][hMoney] = cache_get_row_int(i,13,pl);
	}
	return 1;
}
stock cache_get_row_int(row,idx,con)
{
	new temp[24];
	cache_get_row(row,idx,temp,con);
	temp[0] = strval(temp);
	return temp[0];
}
stock SaveCars()
{
	printf("allcars - %d",allcars);
	for(new carid=0;carid < allcars;carid++)
	{
		format(sesql,sizeof(sesql),"UPDATE `cars` SET ");
		format(ses, sizeof(ses), "Buy='%d' ,", CarsInfo[carid][cBuy]);strcat(sesql, ses, sizeof(sesql));
		format(ses, sizeof(ses), "Owner='%s' ,", Ownerc(carid));strcat(sesql, ses, sizeof(sesql));
		format(ses, sizeof(ses), "Model='%i' ,", CarsInfo[carid][cModel]);strcat(sesql, ses, sizeof(sesql));
		format(ses, sizeof(ses), "Price='%d' ,", CarsInfo[carid][cPrice]);strcat(sesql, ses, sizeof(sesql));
		format(ses, sizeof(ses), "Pos='%f %f %f %f' ,", CarsInfo[carid][cPos][0],CarsInfo[carid][cPos][1] ,CarsInfo[carid][cPos][2] , CarsInfo[carid][cPos][3]);strcat(sesql, ses, sizeof(sesql));
		format(ses, sizeof(ses), "Comp='%i %i %i %i %i %i %i %i %i %i %i %i %i %i' ,",
		CarsInfo[carid][cComp][0],
		CarsInfo[carid][cComp][1],
		CarsInfo[carid][cComp][2],
		CarsInfo[carid][cComp][3],
		CarsInfo[carid][cComp][4],
		CarsInfo[carid][cComp][5],
		CarsInfo[carid][cComp][6],
		CarsInfo[carid][cComp][7],
		CarsInfo[carid][cComp][8],
		CarsInfo[carid][cComp][9],
		CarsInfo[carid][cComp][10],
		CarsInfo[carid][cComp][11],
		CarsInfo[carid][cComp][12]);strcat(sesql, ses, sizeof(sesql));
		format(ses, sizeof(ses), "Colors='%i %i %i' ", CarsInfo[carid][cColors][0], CarsInfo[carid][cColors][1],CarsInfo[carid][cColors][2]);strcat(sesql, ses, sizeof(sesql));
		format(ses, sizeof(ses), "WHERE ID = '%d'",carid);strcat(sesql,ses,sizeof(sesql));
		print(sesql);
		mysql_function_query(pl, sesql, false, "SendQuery", "");
	}
	return 1;
}
stock Money(playerid,money)
{
	PlayerInfo[playerid][pMoney] += money;
	GivePlayerMoney(playerid,money);
	format(ses,sizeof(ses),COL_WHITE"Вы получили "COL_APELS"%i"COL_WHITE" денег",money);
	SendClientMessage(playerid,-1,ses);
	return 1;
}
stock TextDrawC(playerid,textdrawid)
{
	switch(textdrawid)
	{
	    case 0:
	    {
	        Textdrawl[playerid][0] = CreatePlayerTextDraw(playerid, 484.108184, 120.500015, "usebox");
	        PlayerTextDrawLetterSize(playerid, Textdrawl[playerid][0], 0.000000, 23.664815);
	        PlayerTextDrawTextSize(playerid, Textdrawl[playerid][0], 169.947280, 0.000000);
	        PlayerTextDrawAlignment(playerid, Textdrawl[playerid][0], 1);
	        PlayerTextDrawColor(playerid, Textdrawl[playerid][0], 0);
	        PlayerTextDrawUseBox(playerid, Textdrawl[playerid][0], true);
	        PlayerTextDrawBoxColor(playerid, Textdrawl[playerid][0], 102);
	        PlayerTextDrawSetShadow(playerid, Textdrawl[playerid][0], 0);
	        PlayerTextDrawSetOutline(playerid, Textdrawl[playerid][0], 0);
	        PlayerTextDrawFont(playerid, Textdrawl[playerid][0], 0);

	        Textdrawl[playerid][5] = CreatePlayerTextDraw(playerid, 334.524322, 126.583267, "Login Form");
	        PlayerTextDrawLetterSize(playerid, Textdrawl[playerid][5], 0.617729, 2.002498);
	        PlayerTextDrawAlignment(playerid, Textdrawl[playerid][5], 2);
	        PlayerTextDrawColor(playerid, Textdrawl[playerid][5], -20903937);
	        PlayerTextDrawSetShadow(playerid, Textdrawl[playerid][5], 0);
	        PlayerTextDrawSetOutline(playerid, Textdrawl[playerid][5], 1);
	        PlayerTextDrawBackgroundColor(playerid, Textdrawl[playerid][5], 51);
	        PlayerTextDrawFont(playerid, Textdrawl[playerid][5], 2);
	        PlayerTextDrawSetProportional(playerid, Textdrawl[playerid][5], 1);

	        Textdrawl[playerid][2] = CreatePlayerTextDraw(playerid, 479.765747, 155.166687, "LD_SPAC:white");
	        PlayerTextDrawLetterSize(playerid, Textdrawl[playerid][2], 0.000000, 0.000000);
	        PlayerTextDrawTextSize(playerid, Textdrawl[playerid][2], -305.007324, -4.083312);
	        PlayerTextDrawAlignment(playerid, Textdrawl[playerid][2], 1);
	        PlayerTextDrawColor(playerid, Textdrawl[playerid][2], -20903937);
	        PlayerTextDrawSetShadow(playerid, Textdrawl[playerid][2], 0);
	        PlayerTextDrawSetOutline(playerid, Textdrawl[playerid][2], 0);
	        PlayerTextDrawFont(playerid, Textdrawl[playerid][2], 4);

	        Textdrawl[playerid][3] = CreatePlayerTextDraw(playerid, 182.723236, 195.416610, "E-Mail: ~g~insert");
	        PlayerTextDrawLetterSize(playerid, Textdrawl[playerid][3], 0.560000, 2.039999);
	        PlayerTextDrawTextSize(playerid, Textdrawl[playerid][3], 471.332641, 25.083339);
	        PlayerTextDrawAlignment(playerid, Textdrawl[playerid][3], 1);
	        PlayerTextDrawColor(playerid, Textdrawl[playerid][3], -1378294017);
	        PlayerTextDrawUseBox(playerid, Textdrawl[playerid][3], true);
	        PlayerTextDrawBoxColor(playerid, Textdrawl[playerid][3], 434306660);
	        PlayerTextDrawSetShadow(playerid, Textdrawl[playerid][3], 0);
	        PlayerTextDrawSetOutline(playerid, Textdrawl[playerid][3], 1);
	        PlayerTextDrawBackgroundColor(playerid, Textdrawl[playerid][3], 255);
	        PlayerTextDrawFont(playerid, Textdrawl[playerid][3], 1);
	        PlayerTextDrawSetProportional(playerid, Textdrawl[playerid][3], 1);
	        PlayerTextDrawSetSelectable(playerid, Textdrawl[playerid][3], true);

	        Textdrawl[playerid][4]= CreatePlayerTextDraw(playerid, 183.191818, 253.166671, "Pass: ~r~insert");
	        PlayerTextDrawLetterSize(playerid, Textdrawl[playerid][4], 0.560000, 2.039999);
	        PlayerTextDrawTextSize(playerid, Textdrawl[playerid][4], 471.332275, 23.333326);
	        PlayerTextDrawAlignment(playerid, Textdrawl[playerid][4], 1);
	        PlayerTextDrawColor(playerid, Textdrawl[playerid][4], -1378294017);
	        PlayerTextDrawUseBox(playerid, Textdrawl[playerid][4], true);
	        PlayerTextDrawBoxColor(playerid, Textdrawl[playerid][4], 434306660);
	        PlayerTextDrawSetShadow(playerid, Textdrawl[playerid][4], 0);
	        PlayerTextDrawSetOutline(playerid, Textdrawl[playerid][4], 1);
	        PlayerTextDrawBackgroundColor(playerid, Textdrawl[playerid][4], 255);
	        PlayerTextDrawFont(playerid, Textdrawl[playerid][4], 1);
	        PlayerTextDrawSetProportional(playerid, Textdrawl[playerid][4], 1);
	        PlayerTextDrawSetSelectable(playerid, Textdrawl[playerid][4], true);

	        Textdrawl[playerid][1] = CreatePlayerTextDraw(playerid, 333.118499, 312.666778, "Login");
	        PlayerTextDrawLetterSize(playerid, Textdrawl[playerid][1], 0.679573, 2.638335);
	        PlayerTextDrawTextSize(playerid, Textdrawl[playerid][1], 57.628101, 81.083343);
	        PlayerTextDrawAlignment(playerid, Textdrawl[playerid][1], 2);
	        PlayerTextDrawColor(playerid, Textdrawl[playerid][1], -1378294017);
	        PlayerTextDrawUseBox(playerid, Textdrawl[playerid][1], true);
	        PlayerTextDrawBoxColor(playerid, Textdrawl[playerid][1], -5963521);
	        PlayerTextDrawSetShadow(playerid, Textdrawl[playerid][1], 0);
	        PlayerTextDrawSetOutline(playerid, Textdrawl[playerid][1], 1);
	        PlayerTextDrawBackgroundColor(playerid, Textdrawl[playerid][1], 255);
	        PlayerTextDrawFont(playerid, Textdrawl[playerid][1], 2);
	        PlayerTextDrawSetProportional(playerid, Textdrawl[playerid][1], 1);
	        PlayerTextDrawSetSelectable(playerid, Textdrawl[playerid][1], true);
	        
			for(new i=0;i<6;i++) PlayerTextDrawShow(playerid,Textdrawl[playerid][i]);
			SelectTextDraw(playerid, 0xFFC0CBAA);
			return 1;
	    }
	    case 1:
	    {
	        Textdrawr[playerid][0] = CreatePlayerTextDraw(playerid, 604.986816, 1.500000, "usebox");
	        PlayerTextDrawLetterSize(playerid, Textdrawr[playerid][0], 0.000000, 49.396297);
	        PlayerTextDrawTextSize(playerid, Textdrawr[playerid][0], 331.118591, 0.000000);
	        PlayerTextDrawAlignment(playerid, Textdrawr[playerid][0], 1);
	        PlayerTextDrawColor(playerid, Textdrawr[playerid][0], 0);
	        PlayerTextDrawUseBox(playerid, Textdrawr[playerid][0], true);
	        PlayerTextDrawBoxColor(playerid, Textdrawr[playerid][0], 102);
	        PlayerTextDrawSetShadow(playerid, Textdrawr[playerid][0], 0);
	        PlayerTextDrawSetOutline(playerid, Textdrawr[playerid][0], 0);
	        PlayerTextDrawFont(playerid, Textdrawr[playerid][0], 0);

	        Textdrawr[playerid][1] = CreatePlayerTextDraw(playerid, 465.241821, 13.999988, "Register Form");
	        PlayerTextDrawLetterSize(playerid, Textdrawr[playerid][1], 0.449999, 1.600000);
	        PlayerTextDrawAlignment(playerid, Textdrawr[playerid][1], 2);
	        PlayerTextDrawColor(playerid, Textdrawr[playerid][1], -4374017);
	        PlayerTextDrawSetShadow(playerid, Textdrawr[playerid][1], 0);
	        PlayerTextDrawSetOutline(playerid, Textdrawr[playerid][1], 1);
	        PlayerTextDrawBackgroundColor(playerid, Textdrawr[playerid][1], 51);
	        PlayerTextDrawFont(playerid, Textdrawr[playerid][1], 2);
	        PlayerTextDrawSetProportional(playerid, Textdrawr[playerid][1], 1);

	        Textdrawr[playerid][2] = CreatePlayerTextDraw(playerid, 333.587097, 35.583339, "LD_SPAC:white");
	        PlayerTextDrawLetterSize(playerid, Textdrawr[playerid][2], 0.000000, 0.000000);
	        PlayerTextDrawTextSize(playerid, Textdrawr[playerid][2], 268.462707, 5.833328);
	        PlayerTextDrawAlignment(playerid, Textdrawr[playerid][2], 1);
	        PlayerTextDrawColor(playerid, Textdrawr[playerid][2], -4374017);
	        PlayerTextDrawSetShadow(playerid, Textdrawr[playerid][2], 0);
	        PlayerTextDrawSetOutline(playerid, Textdrawr[playerid][2], 0);
	        PlayerTextDrawFont(playerid, Textdrawr[playerid][2], 4);

	        Textdrawr[playerid][3] = CreatePlayerTextDraw(playerid, 340.146148, 62.416683, "Pass: ~r~insert");
	        PlayerTextDrawLetterSize(playerid, Textdrawr[playerid][3], 0.566734, 2.044165);
	        PlayerTextDrawTextSize(playerid, Textdrawr[playerid][3], 594.085266, 22.749996);
	        PlayerTextDrawAlignment(playerid, Textdrawr[playerid][3], 1);
	        PlayerTextDrawColor(playerid, Textdrawr[playerid][3], -1378294017);
	        PlayerTextDrawUseBox(playerid, Textdrawr[playerid][3], true);
	        PlayerTextDrawBoxColor(playerid, Textdrawr[playerid][3], -1309278620);
	        PlayerTextDrawSetShadow(playerid, Textdrawr[playerid][3], 0);
	        PlayerTextDrawSetOutline(playerid, Textdrawr[playerid][3], 1);
	        PlayerTextDrawBackgroundColor(playerid, Textdrawr[playerid][3], 255);
	        PlayerTextDrawFont(playerid, Textdrawr[playerid][3], 1);
	        PlayerTextDrawSetProportional(playerid, Textdrawr[playerid][3], 1);
	        PlayerTextDrawSetSelectable(playerid, Textdrawr[playerid][3], true);

	        Textdrawr[playerid][4] = CreatePlayerTextDraw(playerid, 340.615020, 102.083335, "E-Mail: ~g~insert");
	        PlayerTextDrawLetterSize(playerid, Textdrawr[playerid][4], 0.560000, 2.039999);
	        PlayerTextDrawTextSize(playerid, Textdrawr[playerid][4], 594.553222, 22.750001);
	        PlayerTextDrawAlignment(playerid, Textdrawr[playerid][4], 1);
	        PlayerTextDrawColor(playerid, Textdrawr[playerid][4], -21474338);
	        PlayerTextDrawUseBox(playerid, Textdrawr[playerid][4], true);
	        PlayerTextDrawBoxColor(playerid, Textdrawr[playerid][4], -1309278620);
	        PlayerTextDrawSetShadow(playerid, Textdrawr[playerid][4], 0);
	        PlayerTextDrawSetOutline(playerid, Textdrawr[playerid][4], 1);
	        PlayerTextDrawBackgroundColor(playerid, Textdrawr[playerid][4], 255);
	        PlayerTextDrawFont(playerid, Textdrawr[playerid][4], 1);
	        PlayerTextDrawSetProportional(playerid, Textdrawr[playerid][4], 1);
	        PlayerTextDrawSetSelectable(playerid, Textdrawr[playerid][4], true);

	        Textdrawr[playerid][5] = CreatePlayerTextDraw(playerid, 340.614685, 140.583358, "Date: ~y~insert");
	        PlayerTextDrawLetterSize(playerid, Textdrawr[playerid][5], 0.560000, 2.039999);
	        PlayerTextDrawTextSize(playerid, Textdrawr[playerid][5], 592.679565, 22.166671);
	        PlayerTextDrawAlignment(playerid, Textdrawr[playerid][5], 1);
	        PlayerTextDrawColor(playerid, Textdrawr[playerid][5], -1378294017);
	        PlayerTextDrawUseBox(playerid, Textdrawr[playerid][5], true);
	        PlayerTextDrawBoxColor(playerid, Textdrawr[playerid][5], -1309278620);
	        PlayerTextDrawSetShadow(playerid, Textdrawr[playerid][5], 0);
	        PlayerTextDrawSetOutline(playerid, Textdrawr[playerid][5], 1);
	        PlayerTextDrawBackgroundColor(playerid, Textdrawr[playerid][5], 255);
	        PlayerTextDrawFont(playerid, Textdrawr[playerid][5], 1);
	        PlayerTextDrawSetProportional(playerid, Textdrawr[playerid][5], 1);
	        PlayerTextDrawSetSelectable(playerid, Textdrawr[playerid][5], true);

	        Textdrawr[playerid][6] = CreatePlayerTextDraw(playerid, 340.614715, 177.916671, "City: ~p~Los Santos");
	        PlayerTextDrawLetterSize(playerid, Textdrawr[playerid][6], 0.560000, 2.039999);
	        PlayerTextDrawTextSize(playerid, Textdrawr[playerid][6], 592.211181, 22.166664);
	        PlayerTextDrawAlignment(playerid, Textdrawr[playerid][6], 1);
	        PlayerTextDrawColor(playerid, Textdrawr[playerid][6], -21474338);
	        PlayerTextDrawUseBox(playerid, Textdrawr[playerid][6], true);
	        PlayerTextDrawBoxColor(playerid, Textdrawr[playerid][6], -1309278620);
	        PlayerTextDrawSetShadow(playerid, Textdrawr[playerid][6], 0);
	        PlayerTextDrawSetOutline(playerid, Textdrawr[playerid][6], 1);
	        PlayerTextDrawBackgroundColor(playerid, Textdrawr[playerid][6], 255);
	        PlayerTextDrawFont(playerid, Textdrawr[playerid][6], 1);
	        PlayerTextDrawSetProportional(playerid, Textdrawr[playerid][6], 1);
	        PlayerTextDrawSetSelectable(playerid, Textdrawr[playerid][6], true);

	        Textdrawr[playerid][7] = CreatePlayerTextDraw(playerid, 464.773376, 210.583343, "Male");
	        PlayerTextDrawLetterSize(playerid, Textdrawr[playerid][7], 0.560000, 2.039999);
	        PlayerTextDrawTextSize(playerid, Textdrawr[playerid][7], 38.887256, 41.416667);
	        PlayerTextDrawAlignment(playerid, Textdrawr[playerid][7], 2);
	        PlayerTextDrawColor(playerid, Textdrawr[playerid][7], -1);
	        PlayerTextDrawUseBox(playerid, Textdrawr[playerid][7], true);
	        PlayerTextDrawBoxColor(playerid, Textdrawr[playerid][7], -1309278620);
	        PlayerTextDrawSetShadow(playerid, Textdrawr[playerid][7], 0);
	        PlayerTextDrawSetOutline(playerid, Textdrawr[playerid][7], 1);
	        PlayerTextDrawBackgroundColor(playerid, Textdrawr[playerid][7], 255);
	        PlayerTextDrawFont(playerid, Textdrawr[playerid][7], 1);
	        PlayerTextDrawSetProportional(playerid, Textdrawr[playerid][7], 1);
	        PlayerTextDrawSetSelectable(playerid, Textdrawr[playerid][7], true);

	        Textdrawr[playerid][8] = CreatePlayerTextDraw(playerid, 389.809387, 232.750015, "New Textdraw");
	        PlayerTextDrawLetterSize(playerid, Textdrawr[playerid][8], 0.449999, 1.600000);
	        PlayerTextDrawTextSize(playerid, Textdrawr[playerid][8], 151.332336, 184.916641);
	        PlayerTextDrawAlignment(playerid, Textdrawr[playerid][8], 1);
	        PlayerTextDrawColor(playerid, Textdrawr[playerid][8], -1);
	        PlayerTextDrawUseBox(playerid, Textdrawr[playerid][8], true);
	        PlayerTextDrawBoxColor(playerid, Textdrawr[playerid][8], 0);
	        PlayerTextDrawSetShadow(playerid, Textdrawr[playerid][8], 0);
	        PlayerTextDrawSetOutline(playerid, Textdrawr[playerid][8], 1);
	        PlayerTextDrawBackgroundColor(playerid, Textdrawr[playerid][8], 51);
	        PlayerTextDrawFont(playerid, Textdrawr[playerid][8], 5);
	        PlayerTextDrawSetProportional(playerid, Textdrawr[playerid][8], 1);
	        PlayerTextDrawSetPreviewModel(playerid, Textdrawr[playerid][8], 86);
	        PlayerTextDrawSetPreviewRot(playerid, Textdrawr[playerid][8], 0.000000, 0.000000, 0.000000, 1.000000);

	        Textdrawr[playerid][9] = CreatePlayerTextDraw(playerid, 354.201995, 261.916656, "~<~|");
	        PlayerTextDrawLetterSize(playerid, Textdrawr[playerid][9], 0.560000, 2.039999);
	        PlayerTextDrawTextSize(playerid, Textdrawr[playerid][9], 29.048297, 23.916666);
	        PlayerTextDrawAlignment(playerid, Textdrawr[playerid][9], 2);
	        PlayerTextDrawColor(playerid, Textdrawr[playerid][9], -1);
	        PlayerTextDrawUseBox(playerid, Textdrawr[playerid][9], true);
	        PlayerTextDrawBoxColor(playerid, Textdrawr[playerid][9], -1309278718);
	        PlayerTextDrawSetShadow(playerid, Textdrawr[playerid][9], 0);
	        PlayerTextDrawSetOutline(playerid, Textdrawr[playerid][9], 1);
	        PlayerTextDrawBackgroundColor(playerid, Textdrawr[playerid][9], 51);
	        PlayerTextDrawFont(playerid, Textdrawr[playerid][9], 0);
	        PlayerTextDrawSetProportional(playerid, Textdrawr[playerid][9], 1);
	        PlayerTextDrawSetSelectable(playerid, Textdrawr[playerid][9], true);

	        Textdrawr[playerid][10] = CreatePlayerTextDraw(playerid, 563.162597, 264.250152, "~>~|");
	        PlayerTextDrawLetterSize(playerid, Textdrawr[playerid][10], 0.560000, 2.039999);
	        PlayerTextDrawTextSize(playerid, Textdrawr[playerid][10], 29.516834, 26.250001);
	        PlayerTextDrawAlignment(playerid, Textdrawr[playerid][10], 2);
	        PlayerTextDrawColor(playerid, Textdrawr[playerid][10], -1);
	        PlayerTextDrawUseBox(playerid, Textdrawr[playerid][10], true);
	        PlayerTextDrawBoxColor(playerid, Textdrawr[playerid][10], -1309278718);
	        PlayerTextDrawSetShadow(playerid, Textdrawr[playerid][10], 0);
	        PlayerTextDrawSetOutline(playerid, Textdrawr[playerid][10], 1);
	        PlayerTextDrawBackgroundColor(playerid, Textdrawr[playerid][10], 51);
	        PlayerTextDrawFont(playerid, Textdrawr[playerid][10], 1);
	        PlayerTextDrawSetProportional(playerid, Textdrawr[playerid][10], 1);
	        PlayerTextDrawSetSelectable(playerid, Textdrawr[playerid][10], true);

	        Textdrawr[playerid][11] = CreatePlayerTextDraw(playerid, 474.612152, 422.333251, "Register");
	        PlayerTextDrawLetterSize(playerid, Textdrawr[playerid][11], 0.560000, 2.039999);
	        PlayerTextDrawTextSize(playerid, Textdrawr[playerid][11], 88.081977, 78.749992);
	        PlayerTextDrawAlignment(playerid, Textdrawr[playerid][11], 2);
	        PlayerTextDrawColor(playerid, Textdrawr[playerid][11], -1378294017);
	        PlayerTextDrawUseBox(playerid, Textdrawr[playerid][11], true);
	        PlayerTextDrawBoxColor(playerid, Textdrawr[playerid][11], -21100088);
	        PlayerTextDrawSetShadow(playerid, Textdrawr[playerid][11], 0);
	        PlayerTextDrawSetOutline(playerid, Textdrawr[playerid][11], 1);
	        PlayerTextDrawBackgroundColor(playerid, Textdrawr[playerid][11], 255);
	        PlayerTextDrawFont(playerid, Textdrawr[playerid][11], 1);
	        PlayerTextDrawSetProportional(playerid, Textdrawr[playerid][11], 1);
	        PlayerTextDrawSetSelectable(playerid, Textdrawr[playerid][11], true);
	        
	        PlayerInfo[playerid][pMale] = 1;
	        
			for(new i=0;i<12;i++) PlayerTextDrawShow(playerid,Textdrawr[playerid][i]);
			SelectTextDraw(playerid, 0xFFC0CBAA);
	        return 1;
	    }
	    case 2:
	    {
	        Textbc[playerid][0] = CreatePlayerTextDraw(playerid, 468.178619, 331.666687, "usebox");
	        PlayerTextDrawLetterSize(playerid, Textbc[playerid][0], 0.000000, 9.081480);
	        PlayerTextDrawTextSize(playerid, Textbc[playerid][0], 137.619323, 0.000000);
	        PlayerTextDrawAlignment(playerid, Textbc[playerid][0], 1);
	        PlayerTextDrawColor(playerid, Textbc[playerid][0], 0);
	        PlayerTextDrawUseBox(playerid, Textbc[playerid][0], true);
	        PlayerTextDrawBoxColor(playerid, Textbc[playerid][0], 102);
	        PlayerTextDrawSetShadow(playerid, Textbc[playerid][0], 0);
	        PlayerTextDrawSetOutline(playerid, Textbc[playerid][0], 0);
	        PlayerTextDrawFont(playerid, Textbc[playerid][0], 0);

	        Textbc[playerid][1] = CreatePlayerTextDraw(playerid, 248.658767, 338.333221, "Name: ~g~Infernus");
	        PlayerTextDrawLetterSize(playerid, Textbc[playerid][1], 0.500000, 2.000000);
	        PlayerTextDrawTextSize(playerid, Textbc[playerid][1], 375.412078, 9.333334);
	        PlayerTextDrawAlignment(playerid, Textbc[playerid][1], 1);
	        PlayerTextDrawColor(playerid, Textbc[playerid][1], -5963521);
	        PlayerTextDrawUseBox(playerid, Textbc[playerid][1], true);
	        PlayerTextDrawBoxColor(playerid, Textbc[playerid][1], -1376387315);
	        PlayerTextDrawSetShadow(playerid, Textbc[playerid][1], 0);
	        PlayerTextDrawSetOutline(playerid, Textbc[playerid][1], 1);
	        PlayerTextDrawBackgroundColor(playerid, Textbc[playerid][1], 255);
	        PlayerTextDrawFont(playerid, Textbc[playerid][1], 1);
	        PlayerTextDrawSetProportional(playerid, Textbc[playerid][1], 1);

	        Textbc[playerid][2] = CreatePlayerTextDraw(playerid, 250.658538, 369.249908, "Price: ~r~10000$");
	        PlayerTextDrawLetterSize(playerid, Textbc[playerid][2], 0.500000, 2.000000);
	        PlayerTextDrawTextSize(playerid, Textbc[playerid][2], 373.411621, 0.583333);
	        PlayerTextDrawAlignment(playerid, Textbc[playerid][2], 1);
	        PlayerTextDrawColor(playerid, Textbc[playerid][2], -5963521);
	        PlayerTextDrawUseBox(playerid, Textbc[playerid][2], true);
	        PlayerTextDrawBoxColor(playerid, Textbc[playerid][2], -1376387315);
	        PlayerTextDrawSetShadow(playerid, Textbc[playerid][2], 0);
	        PlayerTextDrawSetOutline(playerid, Textbc[playerid][2], 1);
	        PlayerTextDrawBackgroundColor(playerid, Textbc[playerid][2], 255);
	        PlayerTextDrawFont(playerid, Textbc[playerid][2], 1);
	        PlayerTextDrawSetProportional(playerid, Textbc[playerid][2], 1);

	        Textbc[playerid][3] = CreatePlayerTextDraw(playerid, 274.553222, 405.416687, "Buy car");
	        PlayerTextDrawLetterSize(playerid, Textbc[playerid][3], 0.556690, 2.355832);
	        PlayerTextDrawTextSize(playerid, Textbc[playerid][3], 341.551971, 11.666667);
	        PlayerTextDrawAlignment(playerid, Textbc[playerid][3], 1);
	        PlayerTextDrawColor(playerid, Textbc[playerid][3], -1378294017);
	        PlayerTextDrawUseBox(playerid, Textbc[playerid][3], true);
	        PlayerTextDrawBoxColor(playerid, Textbc[playerid][3], -5963521);
	        PlayerTextDrawSetShadow(playerid, Textbc[playerid][3], 0);
	        PlayerTextDrawSetOutline(playerid, Textbc[playerid][3], 1);
	        PlayerTextDrawBackgroundColor(playerid, Textbc[playerid][3], 255);
	        PlayerTextDrawFont(playerid, Textbc[playerid][3], 1);
	        PlayerTextDrawSetProportional(playerid, Textbc[playerid][3], 1);
	        PlayerTextDrawSetSelectable(playerid, Textbc[playerid][3], true);

	        Textbc[playerid][4] = CreatePlayerTextDraw(playerid, 182.254760, 358.749938, "<");
	        PlayerTextDrawLetterSize(playerid, Textbc[playerid][4], 0.740000, 3.609999);
	        PlayerTextDrawTextSize(playerid, Textbc[playerid][4], 271.743316, 44.333309);
	        PlayerTextDrawAlignment(playerid, Textbc[playerid][4], 2);
	        PlayerTextDrawColor(playerid, Textbc[playerid][4], -5963521);
	        PlayerTextDrawUseBox(playerid, Textbc[playerid][4], true);
	        PlayerTextDrawBoxColor(playerid, Textbc[playerid][4], -1370871153);
	        PlayerTextDrawSetShadow(playerid, Textbc[playerid][4], 0);
	        PlayerTextDrawSetOutline(playerid, Textbc[playerid][4], 1);
	        PlayerTextDrawBackgroundColor(playerid, Textbc[playerid][4], 51);
	        PlayerTextDrawFont(playerid, Textbc[playerid][4], 1);
	        PlayerTextDrawSetProportional(playerid, Textbc[playerid][4], 1);
	        PlayerTextDrawSetSelectable(playerid, Textbc[playerid][4], true);

	        Textbc[playerid][5] = CreatePlayerTextDraw(playerid, 425.417419, 357.583343, ">");
	        PlayerTextDrawLetterSize(playerid, Textbc[playerid][5], 0.740000, 3.609999);
	        PlayerTextDrawTextSize(playerid, Textbc[playerid][5], 464.773834, 50.166656);
	        PlayerTextDrawAlignment(playerid, Textbc[playerid][5], 2);
	        PlayerTextDrawColor(playerid, Textbc[playerid][5], -5963521);
	        PlayerTextDrawUseBox(playerid, Textbc[playerid][5], true);
	        PlayerTextDrawBoxColor(playerid, Textbc[playerid][5], -1699733384);
	        PlayerTextDrawSetShadow(playerid, Textbc[playerid][5], 0);
	        PlayerTextDrawSetOutline(playerid, Textbc[playerid][5], 1);
	        PlayerTextDrawBackgroundColor(playerid, Textbc[playerid][5], 51);
	        PlayerTextDrawFont(playerid, Textbc[playerid][5], 1);
	        PlayerTextDrawSetProportional(playerid, Textbc[playerid][5], 1);
	        PlayerTextDrawSetSelectable(playerid, Textbc[playerid][5], true);
	        
	        for(new i=0;i<6;i++) PlayerTextDrawShow(playerid,Textbc[playerid][i]);
			SelectTextDraw(playerid, 0xFFC0CBAA);
	        return 1;
		}
	}
	return 1;
}
stock memset(aArray[], iValue, iSize = sizeof(aArray)) {
    new iAddress;
    // Store the address of the array
    #emit LOAD.S.pri 12
    #emit STOR.S.pri iAddress
    // Convert the size from cells to bytes
    iSize *= 4;
    // Loop until there is nothing more to fill
    while (iSize > 0) {
        // I have to do this because the FILL instruction doesn't accept a dynamic number.
        if (iSize >= 4096) {
            #emit LOAD.S.alt iAddress
            #emit LOAD.S.pri iValue
            #emit FILL 4096
            iSize -= 4096;
            iAddress += 4096;
        } else if (iSize >= 1024) {
            #emit LOAD.S.alt iAddress
            #emit LOAD.S.pri iValue
            #emit FILL 1024
            iSize -= 1024;
            iAddress += 1024;
        } else if (iSize >= 256) {
            #emit LOAD.S.alt iAddress
            #emit LOAD.S.pri iValue
            #emit FILL 256
            iSize -= 256;
            iAddress += 256;
        } else if (iSize >= 64) {
            #emit LOAD.S.alt iAddress
            #emit LOAD.S.pri iValue
            #emit FILL 64
            iSize -= 64;
            iAddress += 64;
        } else if (iSize >= 16) {
            #emit LOAD.S.alt iAddress
            #emit LOAD.S.pri iValue
            #emit FILL 16
            iSize -= 16;
            iAddress += 16;
        } else {
            #emit LOAD.S.alt iAddress
            #emit LOAD.S.pri iValue
            #emit FILL 4
            iSize -= 4;
            iAddress += 4;
        }
    }
    // aArray is used, just not by its symbol name
    #pragma unused aArray
}
