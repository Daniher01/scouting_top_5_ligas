#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinydashboard)

source("analisis_datos.R")
data <- data_para_input()

# Define UI for application that draws a histogram
dashboardPage(
  dashboardHeader(title = "Scouting Jugadores Ofensivos", titleWidth = "20%"),
  dashboardSidebar(
    sidebarMenu(
      selectInput("in_season",
                  "Temporada:",
                  choices = unique(data$season)),
      
      selectInput("in_liga",
                  "Liga:",
                  choices = NULL),
      
      selectInput("in_team",
                  "Equipo:",
                  choices = NULL),
      
      selectInput("in_player",
                  "Jugador:",
                  choices = NULL)

    )
  ),
  dashboardBody(
    tabBox(
      title = "Métricas Ofensivas",
      # The id lets us use input$tabset1 on the server to find the current tab
      id = "tabset1", width = "100%",
      # Panel 1
      tabPanel("vs Promedio de su liga", 
               fluidRow(
                 valueBoxOutput(width = 6, "cantidad_promedio_liga"),
                 valueBox(width = 6, textOutput("player_name"), tableOutput("card_info_player"), icon = icon("person"))
                 
               ),
               fluidRow(
                 box(width = 4, tableOutput("promedio_liga_tabla")),
                 box(width = 8,  plotOutput("promedio_liga_grafico"))
               ),
               ),
      
      # Panel 2
      tabPanel("Jugadores Similares", 
               fluidRow(
                 valueBox(10 * 2, "Jugadores buscados", icon = icon("credit-card")),
                 
               ))
    ),
  )
)
