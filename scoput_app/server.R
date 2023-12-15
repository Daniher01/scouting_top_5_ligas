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
library(glue)
library(ggtext)


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

  output$promedio_liga <- renderPlot({
    
    data <- data_promedio_liga(input$in_player, input$in_liga)
    promedio_liga <- data$promedio_liga
    
    data_player = data_percentiles_player(promedio_liga, input$in_player)
    
    ggplot(data_player, aes(x = metric, y = percentile)) + 
      geom_bar(aes(y = 1), fill = "#023e8a", stat = "identity",
               width = 1, colour = "white", alpha = 0.6, linetype = "dashed") +
      geom_bar(fill = "#023047", stat = "identity", width = 1,  alpha = 0.8) +
      
      geom_hline(yintercept = 0.25, colour = "white", linetype = "longdash", alpha = 0.5)+
      geom_hline(yintercept = 0.50, colour = "white", linetype = "longdash", alpha = 0.5)+
      geom_hline(yintercept = 0.75, colour = "white", linetype = "longdash", alpha = 0.5)+
      geom_hline(yintercept = 1,    colour = "white", alpha = 0.5) +
      scale_y_continuous(limits = c(-0.1, 1)) +
      coord_polar() +

      geom_label(aes(label = round(p90, 2)), fill = "#e9d8a6", size = 2, color = "black", show.legend = FALSE) +

      labs(fill = "",
           caption = glue("Percentiles respecto a jugadores de la misma posición \n\n Daniel  |  Data: Understat"),
           title = glue("{data_player$player_name[1]} ({data_player$team_title[1]})"),
           subtitle = glue("{input$in_liga} {input$in_season} | Estadísticas cada 90 min.")) +
      theme_minimal() +
      theme(plot.background = element_rect(fill = "white", color = "white"),
            panel.background = element_rect(fill = "white", color = "white"),
            legend.position = "top",
            axis.title.y = element_blank(),
            axis.title.x = element_blank(),
            axis.text.y = element_blank(),
            axis.text.x = element_text(size = 12), # las etiquetas del eje X van a tener un angulo (REVISAR)
            plot.title = element_markdown(hjust = 0.5, size = 16),
            plot.subtitle = element_text(hjust = 0.5, size = 12),
            plot.caption = element_text(size = 10),
            panel.grid.major = element_blank(),
            panel.grid.minor = element_blank(),
            plot.margin = margin(5, 2, 2, 2))


  })
  
  
}
