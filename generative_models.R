# set working directory (works only in RStudio)
setwd( dirname(rstudioapi::getSourceEditorContext()$path) )

# list packages to be used
pkgs <- c("dplyr", "tidyverse", # data wrangling
          "ggplot2", "patchwork", # plotting
          "brms", "rethinking" # stat models
          )

# load or install each of the packages as needed
for ( i in pkgs ) {
  if ( i %in% rownames( installed.packages() ) == F ) install.packages(i) # install if it ain't installed yet
  if ( i %in% names( sessionInfo()$otherPkgs ) == F ) library( i , character.only = T ) # load if it ain't loaded yet
}

# create folders for models, figures, tables and sessions to store results and sessions info in
# prints TRUE and creates the folder if it was not present, prints NULL if the folder was already present
sapply( c("mods", "figs", "tabs", "sess"), function(i) if( !dir.exists(i) ) dir.create(i) )
