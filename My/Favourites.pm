# select and in some cases the order of Favourite repeaters
# ft Yaesu ds Icom dm MD-380 ch chirp
@Favourft = qw{VK2ROZ VK2ROT VK2RBV VK2RCG VK2RCF VK2RWI VK2RMP VK2RBM};
@Favourds = qw{VK2RBV VK2ROT VK2ROZ VK2RCG VK2RCF VK2RWI VK2RMP VK2RBM};
@Favourdm = qw{VK2RCG VK2ROZ VK2ROT VK2RBV VK2RCF VK2RWI VK2RMP VK2RBM};
@Favourch = qw{VK2ROT VK2RBV VK2RCG VK2ROZ VK2RCF VK2RWI VK2RMP VK2RBM};
#
#Talk groups to insert for DMR
#
$FavmarcTG = "1-WW CALL-TG1,1-WW EN-TG13,1-UA EN1-TG113,1-UA EN2-TG123,2-VKZL-TG5,2-VK-TG505,1-TECH-TG100";
@FavmarcTG = split(',',$FavmarcTG);
#
# UR commands to insert for older stlye DStar entries
@FavdstrUR = qw{ Echo-E Status-I Unlink-U LinkR01A-REF001AL LinkD14B-DCS014BL };
#
# Dstar repeaters that get the old style entries
@FavdstrR1 = qw{ VK2RBV VK2RWN VK2RAG VK2HDX VK2PSF };
1;