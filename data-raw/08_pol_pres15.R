## file 08_pol_pres15.R
## author Roger Bivand (April 2019 based on exercises May/June 2015)
## Polish Presidential election data 2015, first (I) and second runoff (II) rounds

download.file("https://prezydent2015.pkw.gov.pl/prezydent_2015_tura1.zip", "prezydent_2015_tura1.zip")
unzip("prezydent_2015_tura1.zip", files="prezydent_2015_tura1.csv")
round1 <- read.csv2("prezydent_2015_tura1.csv", header=TRUE, fileEncoding="CP1250", stringsAsFactors=FALSE)
round1[[3]] <- formatC(round1[[3]], width=6, format="d", flag="0")
not_gminy1 <- round1$TERYT.gminy == "149901" | round1$TERYT.gminy == "229901"
round1a <- round1[!not_gminy1, ]
round1b1 <- aggregate(round1a[, 7:37], list(round1a$TERYT.gminy), sum)

download.file("https://prezydent2015.pkw.gov.pl/wyniki_tura2.zip", "wyniki_tura2.zip")
unzip("wyniki_tura2.zip", files="wyniki_tura2.xls")
# readxl::read_excel() messed up ID column "TERYT gminy"
# https://github.com/tidyverse/readxl/issues/565
# convert to CSV in spreadsheet, leave in CP1250
round2 <- read.csv2("wyniki_tura2.csv", header=TRUE, fileEncoding="CP1250", stringsAsFactors=FALSE)
round2[[3]] <- formatC(round2[[3]], width=6, format="d", flag="0")
not_gminy2 <- round2$TERYT.gminy == "149901" | round2$TERYT.gminy == "229901"
round2a <- round2[!not_gminy2, ]
round2b1 <- aggregate(round2a[, 5:25], list(round2a$TERYT.gminy), sum)
names(round1b1) <- paste("I_", names(round1b1), sep="")
names(round2b1) <- paste("II_", names(round2b1), sep="")
both_rounds1 <- merge(round1b1, round2b1, by.x="I_Group.1", by.y="II_Group.1")

# http://www.codgik.gov.pl/index.php/darmowe-dane/prg.html
# http://www.gugik.gov.pl/geodezja-i-kartografia/pzgik/dane-bez-oplat/dane-z-panstwowego-rejestru-granic-i-powierzchni-jednostek-podzialow-terytorialnych-kraju-prg
# downloaded May 2015 ftp://91.223.135.109/prg/jednostki_administracyjne.zip
# current files differ, possibly some boundary changes
# file size for jednostki_ewidencyjne.* ~ 110 MB; clean and line generalize in GRASS
# v.in.ogr --overwrite input=jednostki_ewidencyjne.shp layer=jednostki_ewidencyjne output=je2 snap=0.01 encoding=CP1250
# v.generalize --overwrite input=je2@rsb type=area output=je_s method=douglas threshold=1000
# v.out.ogr --overwrite input=je_s@rsb output=je_s.gpkg format=GPKG
# after line generalization using GRASS 5.4 MB

# geometries include primary entities, boroughs in three large cities (but only Warsaw
# boroughs TERYT-code in voting data, and urban/rural splits in some entities, not in
# voting data)
library(sf)
je <- st_read("je_s.gpkg", stringsAsFactors=FALSE)
# aggregate administrative areas from urban/rural splits
je$kod6 <- substring(je$jpt_kod_je, 1, 6)
je_agg <- aggregate(je, list(je$kod6), head, n=1)
# drop most columns
je1 <- je_agg[, c("kod6", "jpt_nazwa_", attr(je_agg, "sf_column"))]
# aggregate Łódź and Kraków boroughs not encoded in voting data
Łódź_Kraków <- je1$kod6
Łódź_Kraków[substring(Łódź_Kraków, 1, 4) %in% "1061"] <- "106101"
Łódź_Kraków[substring(Łódź_Kraków, 1, 4) %in% "1261"] <- "126101"
je1a <- aggregate(je1, list(kod6a = Łódź_Kraków), head, n = 1)
je1a$name <- sub("98-220 ", "", sub("\\-GMINA$", "", sub("\\-G$", "", sub(" W GMINIE MIEJSKO-WIEJSKIEJ$", "", sub("OBSZAR WIE$", "", sub(" \\(W\\)$", "", sub("-$", "", sub("WIEŚ$", "", sub(" \\(M\\)$", "", sub("_GM$", "", sub("^GM. ", "", sub("^M_", "M. ", sub("^GM_", "", sub("^ ", "", sub(" $", "", sub(" -", "", sub(" - ", "", sub(" GMINA", "", sub("GMINA ", "", sub("MIASTO", "", sub("OBSZAR WIEJSKI", "", toupper(je1a$jpt_nazwa_))))))))))))))))))))))
je1a$name[grep("1061", je1a$kod6a)] <- "ŁÓDŹ"
je1a$name[grep("1261", je1a$kod6a)] <- "KRAKÓW"
# extract adminitrative area types
je_k8 <- substring(je$jpt_kod_je, 8, 8)
je_k8_agg <- aggregate(je_k8, list(je$kod6), paste, collapse="_")
je_k8_agg1 <- aggregate(je_k8_agg, list(kod6a = Łódź_Kraków), paste, collapse="_")
# correct one error
je_k8_agg1$x[which(je_k8_agg1$x =="2_5_5_4")] <- "5_5_4"
names(je_k8_agg1) <- c("kod6a", "uni_gm", "types")
# construct factor
Types <- rep("Rural", length(je_k8_agg1$types))
Types[grep("1", je_k8_agg1$types)] <- "Urban"
Types[grep("5", je_k8_agg1$types)] <- "Urban/rural"
Types[grep("8", je_k8_agg1$types)] <- "Warsaw Borough"
Types[grep("9", je_k8_agg1$types)] <- "Urban" #ŁÓDŹ and KRAKÓW boroughs
je_k8_agg1$types <- factor(Types)
# merge types and geometries
je1b <- merge(je1a, je_k8_agg1, by.x="kod6a", by.y="kod6a")
# merge geometries and election results
pol_pres15 <- merge(je1b, both_rounds1, by.x="kod6a", by.y="I_Group.1")
# create some proportions
pol_pres15$I_frekw <- with(pol_pres15, I_Liczba.głosów.ważnych / 
I_Liczba.wyborców.uprawnionych.do.głosowania)
pol_pres15$II_frekw <- with(pol_pres15, II_Liczba.głosów.ważnych / 
II_Liczba.wyborców.uprawnionych.do.głosowania)
pol_pres15$I_duda <- with(pol_pres15, I_Andrzej.Sebastian.Duda / 
I_Liczba.głosów.ważnych)
pol_pres15$II_duda <- with(pol_pres15, II_Andrzej.Sebastian.Duda / 
II_Liczba.głosów.ważnych)
pol_pres15$I_komo <- with(pol_pres15,  I_Bronisław.Maria.Komorowski / 
I_Liczba.głosów.ważnych)
pol_pres15$II_komo <- with(pol_pres15,  II_Bronisław.Maria.Komorowski / 
II_Liczba.głosów.ważnych)
# add translated column names (kod6a rendered as TERYT)
attr(pol_pres15, "orig_names") <- names(pol_pres15)
df <- data.frame(nms_pl=names(pol_pres15))
# write.csv(df, "nms_df.csv") # translated by hand outside R
df1 <- read.csv("nms_df.csv", stringsAsFactors=FALSE)
names(pol_pres15) <- df1$nms_en
save(pol_pres15, file="pol_pres15.rda")


