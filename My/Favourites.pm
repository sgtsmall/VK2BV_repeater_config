# select and in some cases the order of Favourite repeaters
# ft Yaesu ds Icom dm MD-380 ch chirp
@Favourft = qw{VK2RBV VK2ROT VK2RCG VK2RCF VK2RWI VK2RMP VK2RBM};
@Favourds = qw{VK2RBV VK2ROT VK2RCG VK2RCF VK2RWI VK2RMP VK2RBM};
@Favourdm = qw{VK2RCG VK2ROT VK2RBV VK2RCF VK2RWI VK2RMP VK2RBM};
@Favourch = qw{VK2ROT VK2RBV VK2RCG VK2RCF VK2RWI VK2RMP VK2RBM};
#
#Talk groups to insert for DMR
## slot-name1-ext1a-TGnum
# becomes channel "name1 ext1a partialcallsign" with talkgroup "name1 ext1a"
# e.g "WW CALL TG1 2RCG", "WW CALL TG1"
$FavmarcTG = "1-WW CALL-TG1-1,1-SPAC-TG5-5,1-WW EN-TG13-13,1-UAEN1-TG113-113,1-UAEN2-TG123-123,1-UAUS-TG133-133,1-UAUK-TG143-143,1-UASP-TG153-153,2-505-VK505-505";
$FavdmrpTG = "2-3800-VKTG-3800,2-3801-VK1TG-3801,2-3802-VK2TG-3802,2-3803-VK3TG-3803,2-3804-VK4TG-3804,2-3805-VK5TG-3805,2-3806-VK6TG-3806,2-3807-VK7TG-3807";
#$FavwicenTG = "1-WICEN TAC1-TG1-1,1-WICEN TAC2-2-2,1-WICEN TAC3-3-3,1-WICEN TAC4-TG4-4,1-WICEN TAC5-TG5-5,1-WICEN TAC6-TG6-6,1-WICEN TAC7-TG7-7,1-WICEN TAC8-TG8-8,1-WICEN TAC9-TG9-9,1-WICEN TAC-10-10,1-WICEN GROUP-101001-101001";
$FavwicenTG = "1-WICEN-TAC2-2,1-WICEN-TAC3-3,1-WICEN-TAC4-4,1-WICEN-TAC6-6,1-WICEN-TAC7-7,1-WICEN-TAC8-8,1-WICEN-TAC10-10,1-WICEN-GROUP-101001";
@FavmarcTG = split(',',$FavmarcTG);
@FavdmrpTG = split(',',$FavdmrpTG);
@FavwicenTG = split(',',$FavwicenTG);
#
#Simplex talk groups only used in contacts
$FavsimpTG = "1-DMR-SIMPLEX-130001";
#becomes TG "VK SIMPLEX"
@FavsimpTG = split(',',$FavsimpTG);
#
#Simplex talk groups only used in contacts
$FavsimpWTG = "1-DMR-SIMPLEX-130001";
#becomes TG "VK SIMPLEX"
@FavsimpWTG = split(',',$FavsimpWTG);
#
# UR commands to insert for older stlye DStar entries
@FavdstrUR = qw{ Echo-E Status-I Unlink-U LinkR01A-REF001AL LinkD14B-DCS014BL };
#
# Dstar repeaters that get the old style entries
@FavdstrR1 = qw{ VK2RBV VK2RWN VK2RAG VK2HDX VK2PSF };
