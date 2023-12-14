#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)


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
  
  output$promedio_liga <- renderTable({
    
    comparacion_promedio <- data_promedio_liga(input$in_player)
    
    comparacion_promedio_clean = comparacion_promedio %>%
        
        select("player_name", "position", "team_title", "time", "goals_p90", "x_g_p90","assists_p90", "x_a_p90", "shots_p90", "key_passes_p90", "npg_p90", "npx_g_p90", "x_g_chain_p90", "x_g_buildup_p90")
  
    # Agregar estilos a la tabla
    #renderTable(comparacion_promedio_clean, include.rownames = FALSE, align = "c", digits = 2, sanitize.text.function = toupper)
    
  })
  
}
