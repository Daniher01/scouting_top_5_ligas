library(dplyr)

data_players = read.csv("../data/players_p90.csv")

data_para_input <- function() {

  return(data_players)
}

data_promedio_liga <- function(player){
  
  target = data_players %>% filter(player_name == player)
  
  promedio_liga = data_players %>% 
    filter(position == target$position & liga == target$liga)
  
  
  return(promedio_liga)
}