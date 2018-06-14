# https://www.r-bloggers.com/using-rvest-to-scrape-an-html-table/
# http://nora.nerc.ac.uk/id/eprint/516735/
# http://www.alex-singleton.com/R-Tutorial-Materials/7-converting-coordinates.pdf
# https://rstudio.github.io/leaflet/

library(rvest)
library(rnrfa)
library(rgdal)
library(leaflet)

vicpark <- read_html("http://www.cardiffparks.org.uk/trees/victoriapark/index.shtml")
vicpark %>% html_nodes(xpath='//*[@id="treestab1"]') %>% html_table()
vic_df$OS <- gsub(" ", "", vic_df$`OS Grid`, fixed=T)
x <- osg_parse(vic_df$OS)
vic_df$East <- x[[1]]
vic_df$North <- x[[2]]

ukgrid = "+init=epsg:27700"
latlong = "+init=epsg:4326"
vic_df$vicID <- 1:nrow(vic_df)
coords <- cbind(Easting = vic_df$East, Northing = vic_df$North)
vic_spatial <- SpatialPointsDataFrame(coords, data = data.frame(vic_df$`Common Name`,vic_df$Name, vic_df$Origin, vic_df$vicID), proj4string = CRS("+init=epsg:27700"))
vicpark_LL <- spTransform(vic_spatial, CRS(latlong))
colnames(vicpark_LL@coords)[colnames(vicpark_LL@coords) =="Easting"] <- "Longitude"
colnames(vicpark_LL@coords)[colnames(vicpark_LL@coords) =="Northing"] <- "Latitude"

m = leaflet(vicpark_LL) %>% addTiles()
# m %>% addCircleMarkers(radius = 15, color=sample(colors(),100), fill=TRUE,  popup = vicpark_LL$vic_df..Common.Name.)
m %>% addMarkers(popup = paste0("<b>",vicpark_LL$vic_df..Common.Name.,"</b><br />",vicpark_LL$vic_df.Origin))

