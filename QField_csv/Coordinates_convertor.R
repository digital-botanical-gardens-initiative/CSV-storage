#close all in the environment
rm(list=ls())

#Install package
install.packages("rgdal")
#Library
library(rgdal)

#Determine the location of the R file and add a separation
path <- getwd()
sep <- "/"

#parameters to fill
file <- "System_JBUF_5.csv" #Place the name of the input CSV here. It has to be in the same folder as the R file.
coord_1 <- "x_coord" #Header of the first coord column
coord_2 <- "y_coord" #Header of the second coord column
suffix <- "WGS84_" #Put the prefix you want to add to the final document

#Creation of the input and final path
path_file <- paste0(path, sep, file)
final_path <- paste0(path, sep, suffix, file)

#Import of the imput CSV
data <- read.csv(file = path_file, header = TRUE, sep = ",")

#sort the data with SPL code
data <- data[order(data$spl_code), ]

#The conversion function
LV95_to_WGS84 <- function(myCoords_LV95) {
  df <- data.frame(myCoords_LV95)
  coordinates(df) <- ~ x_coord + y_coord
  df@proj4string <- CRS("+init=epsg:2056")
  myCoords_WGS84 <- spTransform(df, CRS("+init=epsg:4326"))
  myCoords_WGS84@coords
}

#Replace the LV95 coords by WGS84 coords in the imput CSV
coords_WGS84 <- LV95_to_WGS84(data)
data$x_coord <- coords_WGS84[,1]
data$y_coord <- coords_WGS84[,2]

#Replace the imput CSV by the final CSV
write.csv(data, final_path, row.names = FALSE)