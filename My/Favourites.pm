# select and in some cases the order of Favourite repeaters
# ft Yaesu ds Icom dm MD-380 ch chirp
@Favourft = qw{VK2ROZ VK2ROT VK2RBV VK2RCG VK2RCF VK2RWI VK2RMP VK2RBM};
@Favourds = qw{VK2RBV VK2ROT VK2ROZ VK2RCG VK2RCF VK2RWI VK2RMP VK2RBM};
@Favourdm = qw{VK2RCG VK2ROZ VK2ROT VK2RBV VK2RCF VK2RWI VK2RMP VK2RBM};
@Favourch = qw{VK2ROT VK2RBV VK2RCG VK2ROZ VK2RCF VK2RWI VK2RMP VK2RBM};
#
#Talk groups to insert for DMR
## slot-name1-ext1a-TGnum
# becomes channel "name1 ext1a partialcallsign" with talkgroup "name1 ext1a"
# e.g "WW CALL TG1 2RCG", "WW CALL TG1"
$FavmarcTG = "1-WW CALL-TG1-1,1-WW EN-TG13-13,1-UA EN1-TG113-113,1-UA EN2-TG123-123,2-VKZL-TG5-5,2-VK-TG505-505,1-TECH-TG100-100";
@FavmarcTG = split(',',$FavmarcTG);
#
#Simplex talk groups only used in contacts 
$FavsimpTG = "1-VK-SIMPLEX-505,1-DMR-SIMPLEX-130001";
#becomes TG "VK SIMPLEX"
@FavsimpTG = split(',',$FavsimpTG);
#
#
# UR commands to insert for older stlye DStar entries
@FavdstrUR = qw{ Echo-E Status-I Unlink-U LinkR01A-REF001AL LinkD14B-DCS014BL };
#
# Dstar repeaters that get the old style entries
@FavdstrR1 = qw{ VK2RBV VK2RWN VK2RAG VK2HDX VK2PSF };
1;