#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

# install.packages("fmsb")

library(shiny)
library(dplyr)
library(tidyr)
library(ggplot2)
library(fmsb)
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
  
  ## -------------------- OUTPUTS Para el dashboard
  
  # Primer panel

    
  output$cantidad_promedio_liga <- renderValueBox({
    
    data <- data_promedio_liga(input$in_player, input$in_liga)
    promedio_liga <- data$promedio_liga
    color_df <- color_liga_df(input$in_liga)
    color <- color_df$color_liga
    
    comparacion_promedio <- nrow(promedio_liga)
    texto <- glue("Jugadores comparados en la liga de {input$in_liga} en la misma posición que {input$in_player}")
    
    valueBox(comparacion_promedio, texto, color = color)

  })
  
  output$card_info_player <- render_gt({
    
    data_player_rs = data_para_input() %>%
      filter(player_name == input$in_player) %>%
      select(position, games, time, goals, assists)
    
    titulo <- sprintf("**%s**", input$in_player)
    
    gt(data_player_rs) %>% 
      tab_header(
        title = md(titulo)
      ) %>%
      tab_style(
        style = cell_text(weight = "bold"),
        locations = cells_column_labels(columns = everything())
      )
  })

  output$promedio_liga_grafico <- renderPlot({
    
    data <- data_promedio_liga(input$in_player, input$in_liga)
    promedio_liga <- data$promedio_liga
    color_df <- color_liga_df(input$in_liga)
    color <- color_df$color_liga
    
    
    data_player = data_percentiles_player(promedio_liga, input$in_player)
    
    # calcular el angulo del eje x
    # viz
    n_metrics = length(data_player$metric)
    temp <- 360/n_metrics/2                                      #find the difference in angle between to labels and divide by two.
    myAng <- seq(-temp, -360 + temp, length.out = n_metrics)     #get the angle for every label
    ang <- ifelse(myAng < -90, myAng+180, myAng)                 #rotate label by 180 in some places for readability
    ang <- ifelse(ang < -90, ang+180, ang)
    
    ggplot(data_player, aes(x = metric, y = percentile)) + 
      geom_bar(aes(y = 1), fill = "#bdbdbd", stat = "identity",
               width = 1, colour = "#636363", alpha = 0.6, linetype = "dashed") +
      geom_bar(fill = color, stat = "identity", width = 1,  alpha = 0.8) +
      
      geom_hline(yintercept = 0.25, colour = "white", linetype = "longdash", alpha = 0.5)+
      geom_hline(yintercept = 0.50, colour = "white", linetype = "longdash", alpha = 0.5)+
      geom_hline(yintercept = 0.75, colour = "white", linetype = "longdash", alpha = 0.5)+
      geom_hline(yintercept = 1,    colour = "white", alpha = 0.5) +
      scale_y_continuous(limits = c(-0.1, 1)) +
      coord_polar() +

      geom_label(aes(label = round(p90, 2)), fill = "#e9d8a6", size = 3, color = "black", show.legend = FALSE) +

      labs(fill = "",
           caption = glue("Percentiles respecto a jugadores de la misma posición \n\n  Data: Understat"),
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
            plot.margin = margin(10))


  })
  
  output$promedio_liga_tabla <- renderDT({
    data <- data_promedio_liga(input$in_player, input$in_liga)
    promedio_liga <- data$promedio_liga
    data_player = data_percentiles_player(promedio_liga, input$in_player) %>%
      select(metric, p90, percentile) %>%
      mutate(p90 = round(p90, 2))
    
    datatable(data_player, options = list(pageLength = 10, lengthChange  = FALSE, searching = FALSE))
  })
  
  # Segundo Panel
  
  output$info_box_sim <- renderValueBox({
    
    data_sim <- data_similitud_player(input$in_player)
    
    color_df <- color_liga_df(input$in_liga)
    color <- color_df$color_liga
    
    comparacion_promedio <- nrow(data_sim)
    
    texto <- glue("Jugadores con estilos de juego más similares a {input$in_player} en la misma posición en las 5 principales ligas")
    
    valueBox(width = 6, comparacion_promedio, texto, color = color)
  })
  
  output$card_info_player_simil <- render_gt({
    
    data_player_rs = data_para_input() %>%
      filter(player_name == input$in_player | player_name == input$in_player_simil) %>%
      select(player_name, position, games, time, goals, assists, metricas_p90()) %>%
      mutate(across(ends_with("p90"), ~round(.x, 2))) %>%
      rename(player = player_name,
             xG_p90 = npx_g_p90,
             xA_p90 = x_a_p90,
             goals_p90 = npg_p90,
             xG_chain_p90 = x_g_chain_p90)
    
    gt(data_player_rs) %>% 
      tab_style(
        style = cell_text(weight = "bold"),
        locations = cells_column_labels(columns = everything())
      )  %>% 
      cols_align(
        align = "center",
        columns = everything()
      )
  })
  
  output$similitud_players <- renderDT({
    data_sim <- data_similitud_player(input$in_player)  %>%
      select(player_name, team_title, position, similitud) %>%
      mutate(similitud = paste0(similitud*100,"%"))  %>%
      rename(player = player_name, team = team_title)
    
    datatable(data_sim, options = list(pageLength = 10, lengthChange  = FALSE, searching = FALSE))
  })
  
  output$lista_jugadores_similares <- renderUI({
    
    data_sim <- data_similitud_player(input$in_player)
    
    pickerInput(
      inputId = "in_player_simil",
      label = "Jugador a comparar", 
      choices = data_sim$player_name,
      options = list(
        `live-search` = TRUE)
    )
  })

  output$simil_grafico <- renderPlot({
    
    data_player = data_percentiles_player(player = input$in_player)
    data_player_2 = data_percentiles_player(player = input$in_player_simil)
    
    color_player = "blue"
    color_player_2 = "red"
    
    n_metrics = length(data_player$metric)
    temp <- 360/n_metrics/2                                      #find the difference in angle between to labels and divide by two.
    myAng <- seq(-temp, -360 + temp, length.out = n_metrics)     #get the angle for every label
    ang <- ifelse(myAng < -90, myAng+180, myAng)                 #rotate label by 180 in some places for readability
    ang <- ifelse(ang < -90, ang+180, ang)
    
    ggplot(data_player, aes(x = metric, y = percentile)) + 
      geom_bar(aes(y = 1), fill = "#bdbdbd", stat = "identity",
               width = 1, colour = "#636363", alpha = 0.6, linetype = "dashed") +
      geom_bar(fill = color_player, stat = "identity", width = 1, alpha = 0.2, color = color_player) +
      geom_bar(data = data_player_2,aes(x = metric, y = percentile) ,fill = color_player_2, stat = "identity", width = 1, alpha = 0.2, color = color_player_2) +
      
      
      geom_hline(yintercept = 0.25, colour = "white", linetype = "longdash", alpha = 0.5)+
      geom_hline(yintercept = 0.50, colour = "white", linetype = "longdash", alpha = 0.5)+
      geom_hline(yintercept = 0.75, colour = "white", linetype = "longdash", alpha = 0.5)+
      geom_hline(yintercept = 1,    colour = "white", alpha = 0.5) +
      scale_y_continuous(limits = c(-0.1, 1)) +
      coord_polar() +
      
      labs(fill = "",
           caption = glue("Comparación de jugadores \n\n  Data: Understat"),
           title =
           glue("<b style = 'color: {color_player}'>{data_player$player_name[1]} ({data_player$team_title[1]}) <b style = 'color: black'>vs <b style = 'color: {color_player_2}'>{data_player_2$player_name[1]} ({data_player_2$team_title[1]}) "),
           subtitle = glue("Estadísticas cada 90 min.")) +
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
            plot.margin = margin(10))
    
    

  })
  
}
