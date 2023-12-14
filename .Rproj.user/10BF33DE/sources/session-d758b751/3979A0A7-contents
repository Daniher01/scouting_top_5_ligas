library(readxl)
library(janitor)
library(dplyr)
library(stringr)

# get data de los jugadores
players_laliga_23 = read.csv("data/players_la_liga_23-24.csv") %>% clean_names() %>%
  mutate(liga = as.factor("España"))

players_bundesliga_23 = read.csv("data/players_bundesliga_23-24.csv") %>% clean_names() %>%
  mutate(liga = as.factor("Alemania"))
         
players_premier_23 = read.csv("data/players_epl_23-24.csv") %>% clean_names() %>%
  mutate(liga = as.factor("Inglaterra"))

players_ligue_1_23 = read.csv("data/players_ligue_1_23-24.csv") %>% clean_names() %>%
  mutate(liga = as.factor("Francia"))

players_serie_a_23 = read.csv("data/players_serie_a_23-24.csv") %>% clean_names() %>%
  mutate(liga = as.factor("Italia"))

# procesar los datos
columnas_de_texto = c("id", "player_name", "games", "time", "yellow_cards", "red_cards", "position", "team_title", "liga", "season")

# unir los jugadores de todas las ligas
df_players_23_24 = rbind(players_laliga_23, players_bundesliga_23, players_ligue_1_23, players_premier_23, players_serie_a_23) %>%
  mutate(season = as.factor("23-24"))

players_p90 = df_players_23_24 %>%
  mutate(across(-columnas_de_texto, ~as.numeric(str_replace(.x, "-", "0")))) %>%
  mutate(across(-c(columnas_de_texto), ~(.x/time*90), .names = "{.col}_p90"))

# guardar csv
write.csv(players_p90, "data/players_p90.csv")

