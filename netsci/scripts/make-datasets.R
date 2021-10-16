library(tidyverse)
library(igraph)
library(igraphdata)


ROOT <- here::here("netsci")
DATA <- file.path(ROOT, "data")
RAW  <- file.path(DATA, "raw")


# Political blogs -------------------------------------------------------------------------------------------------

NAME <- "polblogs"

E <- read_csv(file.path(RAW, NAME, "edges.csv")) %>%
    set_names(c("source", "target"))

N <- read_csv(file.path(RAW, NAME, "nodes.csv")) %>%
    select(1L:(ncol(.)-1L)) %>%
    rename(vid = `# index`)

G <- graph_from_data_frame(E, directed = TRUE, vertices = N)
V(G)$affiliation <- if_else(V(G)$value == 1L, "republican", "democrat")

fh <- gzfile(file.path(DATA, str_c(NAME, ".gml.gz")), open = "wb")
write_graph(G, fh, format = "gml")
close(fh)


# Zachary's Karate Club -------------------------------------------------------------------------------------------

NAME <- "karate"

data("karate")
G <- karate
V(G)$faction <- if_else(V(G)$Faction == 1L, "Mr Hi", "John A")
G <- delete_vertex_attr(G, "Faction")

fh <- gzfile(file.path(DATA, str_c(NAME, ".gml.gz")), open = "wb")
write_graph(G, fh, format = "gml")
close(fh)


# Mexican elites --------------------------------------------------------------------------------------------------

NAME <- "mexican-elites"

L <- network::read.paj(file.path(RAW, NAME, str_c(NAME, ".paj")))
G <- intergraph::asIgraph(L$networks$mexican_power.net)
V(G)$start <- L$partitions$mexican_year.clu + 1900L
V(G)$status <- if_else(L$partitions$mexican_military.clu == 1L, "military", "civilian")
V(G)$name <- V(G)$vertex.names

for (attr in c("vertex.names", "x", "y", "z", "na")) G <- delete_vertex_attr(G, attr)
for (attr in c("mexican_power.net", "na")) G <- delete_edge_attr(G, attr)

until <- c(
    "Madero, Francisco" = 1913,
    "Carranza, Venustiano" = 1920,
    "Obregon, Alvaro" = 1928,
    "Calles, Plutarco E." = 1945,
    "Aguilar, Candido" = 1960,
    "Trevino, Jacinto B." = 1971,
    "Portes Gil, Emilio" = 1978,
    "Aleman Gonzalez, Miguel" = 1929,
    "Jara, Heriberto" = 1968,
    "Cardenas, Lazaro" = 1970,
    "Avila Camacho, Manuel" = 1955,
    "Aleman Valdes, Miguel" = 1983,
    "Beteta, Ignacio" = 1988,
    "Beteta, Ramon" = 1965,
    "Beteta, Mario Ramon" = 2004,
    "Sanchez Taboada, Rodolfo" = 1955,
    "Carvajal, Angel" = 1985,
    "Ruiz Cortines, Adolfo" = 1973,
    "Lopez Mateos, Adolfo" = 1969,
    "Margain, Hugo B." = 1997,
    "Gonzalez Blanco, Salomon" = 1992,
    "Serra Rojas, Andres" = 2001,
    "Carrillo Flores, Antonio" = 1986,
    "Ruiz Galindo, Antonio" = 1981,
    "Diaz Ordaz, Gustavo" = 1979,
    "Echeverria Alvarez, Luis" = NA_integer_,
    "Bustamante, Eduardo" = 1991,
    "Ortiz Mena, Antonio" = 2007,
    "Lopez Portillo, Jose" = 2004,
    "Loyo, Gilberto" = 1973,
    "Salinas Lozano, Raul" = 2004,
    "De la Madrid, Miguel" = 2012,
    "Salinas de Gortari, Carlos" = NA_integer_,
    "Aleman Velasco, Miguel" = NA_integer_,
    "Cardenas, Cuauhtemoc" = NA_integer_
)

G$publication <- 1996L
V(G)$death <- until[V(G)$name]
V(G)$end <- as.integer(ifelse(V(G)$death > G$publication | is.na(V(G)$death), G$publication, V(G)$death))


fh <- gzfile(file.path(DATA, str_c(NAME, ".gml.gz")), open = "wb")
write_graph(G, fh, format = "gml")
close(fh)
