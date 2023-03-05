# set working directory (works only in RStudio)
setwd( dirname(rstudioapi::getSourceEditorContext()$path) )

# list packages to be used
pkgs <- c("dplyr", "tidyverse", # data wrangling
          "ggplot2", "patchwork", # plotting
          "ggdag", "dagitty" # causal models
          )

# load or install each of the packages as needed
for ( i in pkgs ) {
  if ( i %in% rownames( installed.packages() ) == F ) install.packages(i) # install if it ain't installed yet
  if ( i %in% names( sessionInfo()$otherPkgs ) == F ) library( i , character.only = T ) # load if it ain't loaded yet
}

# create folders for models, figures, tables and sessions to store results and sessions info in
# prints TRUE and creates the folder if it was not present, prints NULL if the folder was already present
sapply( c("mods", "figs", "tabs", "sess"), function(i) if( !dir.exists(i) ) dir.create(i) )


# ---- building directed acyclic graphs ----

# prepare a list to be filled-in by a bunch of gradually more complex DAGs
d <- list()

# dag no.1: base assumptions only (the arrow)
d$m1 <- dagitty( "dag { C -> D1.i <- ID -> D0.i <- It -> D1.i <- D0.i } " ) %>%
  # add coordinates to create an arrow
  `coordinates<-`( list( x = c(D0.i = 0, D1.i = 1, ID = 1, It = 1, C = 2),
                         y = c(D0.i = 1, D1.i = 1, ID = 0, It = 2, C = 1) ) )

# dag no.2: bi-factor depression (the hammer)
d$m2 <- dagitty( "dag { C -> D1.i <- ID -> D0.i <- It <- F -> D1.i <- D0.i <- F -> It -> D1.i } " ) %>%
  # add coordinates to create an arrow
  `coordinates<-`( list( x = c(D0.i = 0, D1.i = 2, ID = 1, It = 1, C = 3, `F` = 1),
                         y = c(D0.i = 1, D1.i = 1, ID = 0, It = 2, C = 1, `F` = 3) ) )


# ---- session info ----

# write the sessionInfo() into a .txt file
capture.output( sessionInfo(), file = "sess/dbs_postopDEPSY_causal_models_session_info.txt" )
