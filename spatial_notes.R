# Notes on spatial

library(maps)
library(RgoogleMaps)

# State data
states <- map_data("state")
ggplot(states, aes(x=long, y=lat)) +
  geom_polygon(aes(group=group, fill=region), colour="black", fill="white")
merc = CRS("+init=epsg:3857")
ccc <- map("county", "california,contra.costa")

# Google Map
g = get_googlemap("Richmond, CA", scale = 2)
ggmap(g) # Still need to connect with other data (merge?)