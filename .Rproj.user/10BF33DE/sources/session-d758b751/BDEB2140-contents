#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)


data = read.csv("../data/players_p90.csv")

# Define server logic required to draw a histogram
function(input, output, session) {
  
  observeEvent(input$in_season, {
    # Filtrar las ligas basado en la temporada seleccionada
    filtered_ligas <- data[data$season == input$in_season, "liga"]
    
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
  
}
