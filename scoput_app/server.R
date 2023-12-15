#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(dplyr)
library(ggplot2)
library(tidyr)


source("analisis_datos.R")
data <- data_para_input()


# Define server logic required to draw a histogram
function(input, output, session) {
  
  ## Busqueda de jugador para el menu
  
  observeEvent(input$in_season, {
    # Filtrar las ligas basado en la temporada seleccionada
    filtered_ligas <- unique(data[data$season == input$in_season, "liga"])
    
    # Actualizar el input de la liga
    updateSelectInput(session, "in_liga", choices = filtered_ligas)
  })

  observeEvent(input$in_liga, {
    # Filtrar los equipos basado en la liga seleccionada
    filtered_teams <- data[data$liga == input$in_liga, "team_title"]

    # Actualizar el input del equipo
    updateSelectInput(session, "in_team", choices = filtered_teams)
  })
  
  observeEvent(input$in_team, {
    # Filtrar los equipos basado en la liga seleccionada
    filtered_players <- data[data$team_title == input$in_team, "player_name"]
    
    # Actualizar el input del equipo
    updateSelectInput(session, "in_player", choices = filtered_players)
  })
  
  ## OUTPUTS Para el dashboard
  output$player_name <- renderText({
    input$in_player
  })
  
  output$cantidad_promedio_liga <- renderText({
    
    data <- data_promedio_liga(input$in_player, input$in_liga)
    promedio_liga <- data$promedio_liga
    
    comparacion_promedio <- nrow(promedio_liga)

  })

  output$promedio_liga <- renderTable({
    
    data <- data_promedio_liga(input$in_player, input$in_liga)
    promedio_liga <- data$promedio_liga
    
    data_player = data_percentiles_player(promedio_liga, input$in_player)
    
    ggplot(data_player, aes())
    

  })
  
  
}
