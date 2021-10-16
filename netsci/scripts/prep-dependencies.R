PACKAGES <- c(
    "here",
    "tidyverse",
    "ggforce",
    "patchwork",
    "igraph",
    "ggraph",
    "latex2exp"
)
INSTALLED_PACKAGES <- rownames(installed.packages())

for (package in PACKAGES) {
    if (!(package %in% INSTALLED_PACKAGES))
        install.packages(package)
}
