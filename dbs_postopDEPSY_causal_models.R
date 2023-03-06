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

# prepare a list with names for each DAG to be build
nms <- list( m1 = "dag #1: base assumptions only",
             m2 = "dag #2: bi-factor depression",
             m3 = "dag #3: bi-factor depression & LEDD",
             m4 = "dag #4: bi-factor depression & medication",
             m5 = "dag #5: bi-factor depression & medication affected by connectivity",
             m6 = "dag #6: bi-factor depression & medication affected by connectivity stratified by regions"
             )

# one-by-one build the DAGs
d <- list(
  m1 = dagitty( "dag { C -> D1.i <- ID -> D0.i <- It -> D1.i <- D0.i } " ),
  m2 = dagitty( "dag { C -> D1.i <- ID -> D0.i <- It <- F -> D1.i <- D0.i <- F -> It -> D1.i } " ),
  m3 = dagitty( "dag { C -> D1.i <- L1 <- ID -> D0.i -> D1.i <- ID -> L0 -> D0.i; L0 -> L1; D0.i <- It -> D1.i <- F -> D0.i; F -> It } " ),
  m4 = dagitty( "dag { C -> D1.i <- L1 <- ID -> D0.i -> D1.i <- ID -> L0 -> D0.i; D0.i <- It -> D1.i <- F -> D0.i; D1.i <- A1 <-ID -> A0 -> D0.i; F -> It; L0 -> L1; A0 -> A1 } " ),
  m5 = dagitty( "dag { C -> D1.i <- L1 <- ID -> D0.i -> D1.i <- ID -> L0 -> D0.i; D0.i <- It -> D1.i <- F -> D0.i; D1.i <- A1 <-ID -> A0 -> D0.i; F -> It; L0 -> L1; A0 -> A1; A1 <- C -> L1 } " ),
  m6 = dagitty( "dag { R -> C -> D1.i <- L1 <- ID -> D0.i -> D1.i <- ID -> L0 -> D0.i; D0.i <- It -> D1.i <- F -> D0.i; D1.i <- A1 <-ID -> A0 -> D0.i; F -> It; L0 -> L1; A0 -> A1; A1 <- C -> L1 } " )
)

# add coordinates to all DAGs
for( i in names(d) ) d[[i]] <- d[[i]] %>% `coordinates<-`(
  # listing coordinates for the most expansive DAG (m4 and m5), will apply to the smaller ones as well
  list( x = c(D0.i = 0, D1.i = 2, ID = 1, It = 1, C = 3, `F` = 1, L0 = 0, L1 = 2, A0 = 0, A1 = 2, R = 3),
        y = c(D0.i = 2, D1.i = 2, ID = 1, It = 3, C = 2, `F` = 4, L0 = 0, L1 = 0, A0 = 5, A1 = 5, R = 0) )
)

# separately plot each of the DAGs
f <- lapply( names(d), function(i) d[[i]] %>% ggdag() + theme_dag(base_size = 13) + labs( title = nms[[i]] ) + theme( plot.title = element_text(face = "bold") ) )

# arrange the DAGs intro a nice single plot
( f[[1]] | f[[2]] | f[[3]] ) / ( f[[4]] | f[[5]] ) / ( f[[6]] ) + plot_layout( heights = c(1,1.5,2) )

# save it
ggsave( "figs/fig_1_causal_representation.jpeg", width = 1.2 * 11.8, height = 1.2 * 13.1 )


# ---- session info ----

# write the sessionInfo() into a .txt file
capture.output( sessionInfo(), file = "sess/dbs_postopDEPSY_causal_models_session_info.txt" )
