#!/bin/bash
cd output
rsync vkrepdir.csv ~/Google\ Drive/VK2BV/MemberRead/Aust\ Repeater\ Data/
#rsync vkrep.csv ~/Google\ Drive/VK2BV/MemberRead/Aust\ Repeater\ Data/
rsync vkrepstd.csv ~/Google\ Drive/VK2BV/MemberRead/Aust\ Repeater\ Data/
rsync YAESU/FT-1D/vkrepft-1dradms6.csv ~/Google\ Drive/VK2BV/MemberRead/Yaesu/
rsync YAESU/FT-2D/vkrepft-2drrts.csv ~/Google\ Drive/VK2BV/MemberRead/Yaesu/
rsync YAESU/FTM-400D/vkrepftm-400dr*.csv ~/Google\ Drive/VK2BV/MemberRead/Yaesu/

##rsync vkrepftm-100drrts*.csv ~/Google\ Drive/VK2BV/MemberRead/Yaesu/
rsync ICOM/IcomDStarplus.zip ~/Google\ Drive/VK2BV/MemberRead/DStar\ Radio\ Config/
rsync ICOM/IcomDStar.zip ~/Google\ Drive/VK2BV/MemberRead/DStar\ Radio\ Config/
rsync ICOM/IcomDStar.zip ~/Google\ Drive/VK2BV/MemberRead/DStar\ Radio\ Config/ICOM\ 51A/
rsync ICOM/IcomDStarplus.zip ~/Google\ Drive/VK2BV/MemberRead/DStar\ Radio\ Config/ICOM\ 51A\ AnnivPlus/
rsync ICOM/IcomDStarplus.zip ~/Google\ Drive/VK2BV/MemberRead/DStar\ Radio\ Config/ICOM\ 5100\ 1.2/
#
rsync wicen.zip ~/Google\ Drive/VK2BV/MemberRead/
rsync chirpx.csv ~/Google\ Drive/VK2BV/MemberRead/
