library(DBI)
library(RSQLite)
library(dplyr) # this will automatically load dbplyr
library(dbplyr)

setwd("C:/Users/IIDS/OneDrive - Institute for Integrated Development Studies/Desktop/R Studio/SQLite")

portaldb <- dbConnect(SQLite(), "portal_mammals.sqlite")
dbListTables(portaldb)
dbListFields(portaldb, "plots")
surveys <- tbl(portaldb, "surveys")
surveys
surveys_df <- collect(surveys)

count_query <- "SELECT species_id, COUNT(*) FROM surveys
GROUP BY species_id"

dbGetQuery(portaldb, count_query) # This and below this command works the same
## THis will return database in R 
tbl(portaldb, sql(count_query))

count_data <- tbl(portaldb, sql(count_query)) %>% collect()
