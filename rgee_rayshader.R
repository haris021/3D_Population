#' @author Antony Barja :3 
# Requeriments
library(rgee)
library(rayshader)
library(raster)
library(sf)
library(magick)
ee_Initialize()

# Preprocesing population data in rgee
pop <- ee$ImageCollection$Dataset$WorldPop_GP_100m_pop
pop_max <- pop$max()

# st -> featurecollection 
pakistan <- st_read("gpkg/Pakistan.gpkg")

# Define new extent for country
extent <- pakistan %>% 
  st_bbox() %>% 
  st_as_sfc() %>% 
  sf_as_ee()

# Simple visualization of Peru box
# Map$addLayer(extent)

# Image to raster o stars ~ 185 s
get_pop_data <- ee_as_raster(
  image = pop_max,
  region = extent,
  dsn = "/home/ambarja/Documentos/github/rgee3D/population.tif",
  scale = 1000
)

# Working in local with raster
pop_local <- raster("population_2022_05_09_14_16_23.tif") %>%
  crop(pakistan) %>%
  mask(pakistan)

# Preparing raster for rayshader 
pop_local <- raster_to_matrix(pop_local)

# Visualization 3D
pop_local %>%
  sphere_shade(
    texture = create_texture(
      "#013220", "#013220","#013220",
      "#013220", "#ffffff")
    ) %>%
  plot_3d(pop_local ,
          zscale = 15,
          fov = 0, theta = 0,
          zoom = 0.9,
          phi = 35,
          soliddepth = -20,
          solidcolor = "#013220", shadow = TRUE, shadowdepth = -15,
          shadowcolor = "#013220", background = "white",
          windowsize = c(1200, 1000)
          )

# render_snapshot(clear=TRUE)
render_snapshot(
  "3D_population_Punjab.png"
  )

# Magick :3 (Customization)
edited <- image_read("3D_population_Pakistan.png")
edited %>%
  image_annotate(
    "Population density  Pakistan 2020\n",
    gravity = "NorthWest",font = "Bodoni MT",
    size = 90, degrees = 0, location = "+20+10"
    ) %>% 
  image_annotate(
    "Source: WorlPop | Created by: Haris Mushtaq | @haris0021",
    font = "ScriptS", gravity = "SouthWest",
    size = 15, degrees = 0, location = "+560+10"
    ) 

