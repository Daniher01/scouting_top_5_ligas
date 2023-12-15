library(dplyr)
library(tidyr)

data_players = read.csv("../data/players_p90.csv")

metricas_p90 <- function(){
  return(c("npx_g_p90", "x_a_p90", "shots_p90", "npg_p90", "key_passes_p90",   "x_g_chain_p90", "x_g_buildup_p90"))
}

metricas_percentil <- function(){
  return(c("npx_g_p90_percentil", "x_a_p90_percentil", "shots_p90_percentil",  "npg_p90_percentil", "key_passes_p90_percentil", "x_g_chain_p90_percentil", "x_g_buildup_p90_percentil"))
}

columnas_historico <- function(){
  return(c("player_name", "position", "team_title", "goals", "assists", "time", "games"))
}

data_para_input <- function() {

  return(data_players)
}

data_promedio_liga <- function(player, liga_in){
  
  target = data_players %>% filter(player_name == player & liga == liga_in)
  
  promedio_liga = data_players %>% 
    filter(position == target$position & liga == target$liga)
  
  
  return(list(promedio_liga = promedio_liga, player = target))
}

data_percentiles_player <- function(data, player){
  
  # obtener percentil
  liga_percentil = data %>%
    mutate(across(ends_with("p90"), ~round(percent_rank(.x)*100, 1), .names = "{.col}_percentil"))
  
  #conbinar columnas
  ## para metricas p90
  players_p90_long = liga_percentil %>%
    pivot_longer(cols = metricas_p90(), names_to = "metric", values_to = "p90")
  
  players_percentile_long = liga_percentil %>%
    pivot_longer(cols = metricas_percentil(), names_to = "metric", values_to = "percentile")
  
  data_return = players_p90_long %>%
    bind_cols(players_percentile_long %>% select(percentile)) %>%
    filter(player_name == player) %>%
    mutate(metric = case_when(metric == "npx_g_p90" ~ "xG",
                              metric == "x_a_p90" ~ "xA",
                              metric == "shots_p90" ~ "Shots",
                              metric == "key_passes_p90" ~ "Key Passes",
                              metric == "npg_p90" ~ "Goals (NP)",
                              metric == "x_g_chain_p90" ~ "xG Chain",
                              metric == "x_g_buildup_p90" ~ "xG Buildup")) %>%
    select(columnas_historico(), metric, p90, percentile)
    
  
  return(data_return)
  
}



