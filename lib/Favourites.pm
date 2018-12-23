# select and in some cases the order of Favourite repeaters
# ft Yaesu ds Icom dm MD-380 ch chirp
@Favourft = qw{VK2RBV VK2ROT VK2RCG VK2RCF VK2RWI VK2RMP VK2RBM};
@Favourds = qw{VK2RBV VK2ROT VK2RCG VK2RCF VK2RWI VK2RMP VK2RBM};
@Favourdm = qw{VK2RCG VK2ROT VK2RBV VK2RCF VK2RWI VK2RMP VK2RBM};
@Favourch = qw{VK2ROT VK2RBV VK2RCG VK2RCF VK2RWI VK2RMP VK2RBM};
#
@Favtsqlr = qw{VK2RRE-2 VK8RKT-2 VK7RHT-2 VK3RNW-2 VK4RRC-2 VK4RBN-2 VK2RBV-7 VK4RPH-7 VK2RBM-7 VK3RCU-7 VK2RCF-7 VK2RFG-7 VK7RAD-7 VK3XEM-7 VK3RDX-7 VK5RSC-7};
#Talk groups to insert for DMR
## slot-name1-ext1a-TGnum
# becomes channel "name1 ext1a partialcallsign" with talkgroup "name1 ext1a"
# e.g "WW CALL TG1 2RCG", "WW CALL TG1"
# These dmr do not use delault 1-9-LOCAL-9 entry.
@FavDMRno1_9 = qw { MMDVSB MMDVSD MMDVSX MMDVDB MMDVDD MMDVDX WICENS SHARKB SHARKD SHARKX };
#DMRPlus repeaters
@FavDMRP = qw{
  100-VK1RAA-BM-1 101-VK1RBM-IPSC2-1 229-VK2RAO-IPSC2-1 201-VK2RCG-IPSC2-2 230-VK2RCV-IPSC2-2
  224-VK2RGN-IPSC2-2 223-VK2RHR-IPSC2-2 225-VK2RHT-IPSC2-2 212-VK2RLE-IPSC2-2 235-VK2RMB-IPSC2-2
  207-VK2RRW-IPSC2-2 299-VK2RWI-IPSC2-2 315-VK3RGL-IPSC2-3 304-VK3RMC-IPSC2-3 309-VK3RPS-IPSC2-3
  313-VK3RPT-IPSC2-3 300-VK3RSU-IPSC2-3 301-VK3RTE-IPSC2-3 302-VK3RZU-IPSC2-3 415-VK4RBK-IPSC2-4
  417-VK4RBT-IPSC2-4 410-VK4RBX-IPSC2-4 404-VK4RDU-IPSC2-4 416-VK4RLU-IPSC2-4 401-VK4RMC-IPSC2-4
  413-VK4RNX-IPSC2-4 402-VK4RTQ-IPSC2-4 502-VK5RSF-IPSC2-5 603-VK6RDM-IPSC2-6 605-VK6RLM-IPSC2-6
  703-VK7RCR-IPSC2-7 704-VK7RJG-IPSC2-7 205-VK2RAG-BM-2
  218-VK2RCW-BM-2 253-VK2RFI-WICA-2 254-KURDMR-WICA-2 219-VK2RGP-BM-2 206-VK2RHK-BM-2 222-VK2RHX-BM-2
  351-VK3RMM-BM-3 351-VK3RGV-BM-3 352-VK3RWW-BM-3
  407-VK4REG-BM-4 400-VK4RGX-BM-4 411-VK4RSA-BM-4 451-VK4RCN-BM-4 452-VK4RSL-BM-4
  501-VK5REX-BM-5
  606-VK6RGF-BM-6 652-VK6RLX-BM-6 653-VK6RPT-BM-6 654-VK6RRR-BM-6
  2113-VK2PS2-IPSC2-2 2114-VK2PSF-IPSC2-2 2115-DV4DMR-REF-2
  2117-MMDVSB-MMDVMB-2 2118-MMDVSD-MMDVMD-2 2119-MMDVSX-MMDVMX-2 2120-MMDVSI-IPSC2-2
  2121-MMDVDB-MMDVMB-2 2122-MMDVDD-MMDVMD-2 2123-MMDVDX-MMDVMX-2 2124-MMDVDI-IPSC2-2
  2125-SHARKB-SHARKB-2 2126-SHARKD-SHARKD-2 2127-SHARKX-SHARKX-2 2128-SHARKI-IPSC2-2 };
#  604-VK6RPT-IPSC2-6 704-VK7RAA-IPSC2-7
#@FavmarcTG = qw{ 1-1-WW-1 1-EN-WW-13 1-113-EN-113};
@FavmarcTG = qw{ };
#$FavmarcWTG  = "1-113-EN-113,1-123-EN-123,1-153-SP-153,2-505-T-505";
@FavmarcWTG  = qw{ 2-505-T-505 };
#@FavdmbmAPRS = qw{ 2-APRS-E-505999 };

@FavdmrefTG = qw{
  2-9-LOCAL-9 2-8-AREA-8 2-4800-0-4800 2-4801-1-4801 2-4802-2-4802 2-4803-3-4803
  2-4804-4-4804 2-4805-5-4805 2-4806-6-4806 2-4807-7-4807 2-4808-8-4808 2-4809-9-4809
  2-4810-W-4810 2-4000-R-4000 2-9990-E-9990 };

@FavdmrpTG = qw{
  1-8-AREA-8 2-9-LOCAL-9 2-3800-0-3800 2-3801-1-3801 2-3802-2-3802 2-3803-3-3803 2-3804-4-3804
  2-3805-5-3805 2-3806-6-3806 2-3807-7-3807 2-3808-8-3808 1-3809-9-3809 1-3810-A-3810 };

@FavdmrpTGcontact = qw {
  1-133-US-133 1-143-UK-143 };

@FavdmrOspotTG = qw{ 2-9000-PQ-9000 2-9001-IP-9001 2-9998-AC-9998 2-9999-LE-9999 2-4000-DMRG-4000 2-5000-DMRG-5000 };
#@FavsharkDMRGTO = qw{ 2-8-AREA-8 2-6-BMXLX-6 2-9000-PQ-9000 2-9001-IP-9001 2-9998-AC-9998 2-9999-LE-9999 };
#@FavsharkDMRGTPO = qw{
#  2-4000-DMRG-84000 2-4800-DMRG-84800 2-4801-DMRG-84801 2-4802-DMRG-84802 2-4803-DMRG-84803
#  2-4804-DMRG-84804 2-4805-DMRG-84805 2-4806-DMRG-84806 2-4807-DMRG-84807 2-4808-DMRG-84808
#  2-4809-DMRG-84809 2-4810-DMRG-84810 2-5000-DMRG-85000  };
@FavsharkDMRGTB = qw{ 2-PROF-BM-90000 2-505-T-505
    2-53099-DMRG-53099 2-31075-DMRG-31075 };
@FavsharkDMRGTPB = qw{ 2-APRS-E-505999 2-PRIV-CALL-9990 };

@FavsharkDMRGTD = qw{ 2-PROF-DP-90001
    };
@FavsharkDMRGTPD = qw{
  };

@FavsharkDMRGTX = qw{ 2-PROF-XL-90002 };
@FavsharkDMRGTPX = qw{
    };
@FavsharkDMRGTI = qw{ 2-PROF-DP-90001
        };
@FavsharkDMRGTPI = qw{
      };

#@FavmmdvmDMRGTB = qw{ 2-9-LOCAL-9 2-505-T-505 2-5050-DMRG-5050 2-5051-DMRG-5051 2-5052-DMRG-5052 2-5053-DMRG-5053
#  2-5054-DMRG-5054 2-5055-DMRG-5055 2-5056-DMRG-5056 2-5057-DMRG-5057 2-5058-DMRG-5058 2-5059-DMRG-5059
#  2-50599-DMRG-50599 2-50593-DMRG-50593 2-31075-DMRG-31075 };
@FavmmdvmDMRGTB = qw{ 2-6-BMXLX-6 2-8-AREA-8 2-505-T-505
  2-50593-DMRG-50593 2-31075-DMRG-31075 };
@FavmmdvmDMRGTPB = qw{ 2-APRS-E-505999 2-94000-DMRG-94000 2-95000-DMRG-95000 };
@FavmmdvmDMRGTD = qw{ 2-9-LOCAL-9 2-6-BMXLX-6};
@FavmmdvmDMRGTPD = qw{
  2-4000-DMRP-84000 2-4800-DMRP-84800 2-4801-DMRP-84801 2-4802-DMRP-84802 2-4803-DMRP-84803
  2-4804-DMRP-84804 2-4805-DMRP-84805 2-4806-DMRP-84806 2-4807-DMRP-84807 2-4808-DMRP-84808
  2-4809-DMRP-84809 2-4810-DMRP-84810 2-5000-DMRP-85000  };
@FavmmdvmDMRGTX = qw{ 2-8-AREA-8 2-9-LOCAL-9 };
@FavmmdvmDMRGTPX = qw {
  2-64000-XLXD-64000 2-65000-XLXS-65000 2-X299-DMRG-68299 2-X389-DMRG-68389 2-X313-DMRG-68313
  2-XLXA-DMRG-64001 2-XLXB-DMRG-64002 2-XLXC-DMRG-64003 2-XLXD-DMRG-64004
  2-XLXE-DMRG-64005 2-XLXF-DMRG-64006 2-XLXG-DMRG-64007 };
#$FavwicenTG = "1-WICEN TAC1-TG1-1,1-WICEN TAC2-2-2,1-WICEN TAC3-3-3,1-WICEN TAC4-TG4-4,1-WICEN TAC5-TG5-5,1-WICEN 6-TG6-6,1-WICEN TAC7-TG7-7,1-WICEN TAC8-TG8-8,1-WICEN TAC9-TG9-9,1-WICEN TAC-10-10,1-WICEN GROUP-101001-101001";
# fill in contacts
@FavwicenTG = qw{ 1-TAC2-WICEN-2 1-TAC3-WICEN-3 2-TAC4-WICEN-4 2-TAC5-WICEN-5 2-6-BMXLX-6 2-TAC7-WICEN-7 2-TAC10-WICEN-10 1-WICEN-GROUP-101001 };

#Kurrajong channels talk groups
@FavwicenchTGK = qw{ 1-TAC1-WICEN-1 1-TAC2-WICEN-2 1-TAC3-WICEN-3 2-TAC4-WICEN-4 2-TAC5-WICEN-5 2-6-BMXLX-6 };
#Wicen Emerg Channels talk groups
@FavwicenchTGE =qw{ 1-TAC7-WICEN-07 1-TAC8-WICEN-08 2-TAC9-WICEN-09 2-TAC10-WICEN-10 };
#Contacts only
@Favwicencontact = qw{
1-WICEN-MOB01-103001 1-WICEN-MOB02-103002 1-WICEN-MOB03-103003 1-WICEN-MOB04-103004 1-WICEN-MOB05-103005
1-WICEN-DMR01-102001 1-WICEN-DMR02-102002 1-WICEN-DMR03-102003 1-WICEN-DMR04-102004 1-WICEN-DMR05-102005
1-WICEN-DMR06-102006 1-WICEN-DMR07-102007 1-WICEN-DMR08-102008 1-WICEN-DMR09-102009 1-WICEN-DMR10-102010
1-WICEN-DMR11-102011 1-WICEN-DMR12-102012 1-WICEN-DMR13-102013 1-WICEN-DMR14-102014 1-WICEN-DMR15-102015
1-WICEN-DMR16-102016 1-WICEN-DMR17-102017 1-WICEN-DMR18-102018 1-WICEN-DMR19-102019 1-WICEN-DMR20-102020
1-WICEN-DMR21-102021 1-WICEN-DMR22-102022 1-WICEN-DMR30-102030};


@Favopenspotrx = qw { MMDVDB MMDVDD MMDVDX MMDVSB MMDVSD MMDVSX DV4DMR SHARKB SHARKD SHARKX SHARKI };
#
#becomes TG "VK SIMPLEX"
@FavsimpTG = qw { 1-DMR-SIMPLEX-130001 };
#
#Simplex talk groups only used in contacts
@FavsimpWTG = qw { 1-DMR-SIMPLEX-130001 };

#becomes TG "VK SIMPLEX"
#
@Favrxgrplist = qw { RXGR1;8;9;505 Openspot;6;7;8;9 };

#@Favrxgrplist = split (',',$Favrxgrplist);
# UR commands to insert for older stlye DStar entries
@FavdstrUR = qw{ Echo-E Status-I Unlink-U LinkR01A-REF001AL LinkD14B-DCS014BL };
#
# Dstar repeaters that get the old style entries
@FavdstrR1 = qw{ VK2RBV VK2RWN VK2RAG VK2HDX VK2PSF };
