#Closes all in the environment
rm(list=ls())

#Installs package (If you don't already have rgdal, execute by retiring the #)
#install.packages("rgdal")
#install.packages("dplyr")

#Loads the used library
library(rgdal)
library(dplyr)

#Determines the location of the R file and add a separation
path <- "C:/Users/edoua/Desktop/DBGI_project/CSV-storage/QField_csv"
sep <- "/"

#parameters to fill
file <- "Succulent_greenhouse.csv" #Place the name of the input CSV here. It has to be in the same folder as the R file.
file_tsv <- "Succulent_greenhouse.tsv" #Neeeded to make the final tsv
coord_1 <- "x_coord" #Header of the first coord column
coord_2 <- "y_coord" #Header of the second coord column
transit_suffix <- "WGS84_transit_" #Put the prefix you want to add to the final document
final_suffix <- "WGS84_"
do_not_open <- "do_not_open_succulent.csv"

#Creation of the input , transition and final path
path_file <- paste0(path, sep, file)
transit_path <- paste0(path, sep, transit_suffix, file)
final_path_do_not_open <- paste0(path, sep, do_not_open)
final_path <- paste0(path, sep, final_suffix, file)
final_path_tsv <- paste0(path, sep, final_suffix,file_tsv)

#Import of the input CSV
data_raw <- read.csv(file = path_file, header = TRUE)

#sort the data with SPL code
data_raw <- data_raw[order(data_raw$spl_code), ]

#The conversion function from LV95 to WGS84
LV95_to_WGS84 <- function(myCoords_LV95) {
  df <- data.frame(myCoords_LV95)
  coordinates(df) <- ~ x_coord + y_coord
  df@proj4string <- CRS("+init=epsg:2056")
  myCoords_WGS84 <- spTransform(df, CRS("+init=epsg:4326"))
  myCoords_WGS84@coords
}

#Replaces the LV95 coords by WGS84 coords in the imput CSV
coords_WGS84 <- LV95_to_WGS84(data_raw)
data_raw$x_coord <- coords_WGS84[,1]
data_raw$y_coord <- coords_WGS84[,2]

#Rearranges the order of the columns
data_raw <- data_raw %>% select(Plant_ID, Panel, General, Detail, Cut, Panel.Labe, x_coord, y_coord, fid, spl_code, mg)

#Creates the transition CSV
write.csv(data_raw, transit_path, row.names = FALSE)

# reads the transition CSV into data frame
df1 <- read.csv(file = transit_path, header = TRUE)

#If statement to manage when the final CSV is not yet created.
#Import the old final CSV and merges it with the transition CSV, without making duplicates. Then rewrites the final CSV, with mention do not open.
#If there is an old final CSV
if(file.exists(final_path_do_not_open)){
  df2 <- read.csv(file = final_path_do_not_open, header = TRUE)
  combined <- rbind(df2, df1)
  combined <- combined %>%
    distinct(spl_code, .keep_all = TRUE)
  write.csv(combined, final_path_do_not_open, row.names = FALSE)
  #If there isn't any final CSV
  } else {
    write.csv(df1, final_path_do_not_open, row.names = FALSE)
  }

#Make final CSV and TSV that can be edited and opened without problems, because continuously completely rewritten. Do not causes the risk to corrupt the code.
write.csv(df2, final_path, row.names = FALSE)
write.table(df2, final_path, row.names = FALSE, sep = "/t")
