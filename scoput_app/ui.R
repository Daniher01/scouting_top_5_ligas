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
library(shinyWidgets)
library(gt)
library(DT)

library(rsconnect)
rsconnect::setAccountInfo(name='dhernandezm',
                          token='E1321464D5B33C8373C958B2DC5BF98E',
                          secret='WksE8QXGCypUtlKkKNF8uFbyaRgKK5gLaUOOSU7E')
deployApp(forceUpdate = TRUE)

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
                  box(width = 6, tableOutput("card_info_player"))
                 
               ),
               fluidRow(
                 box(width = 6, DTOutput("promedio_liga_tabla")),
                 box(width = 6,  plotOutput("promedio_liga_grafico"))
               ),
               ),
      
      # Panel 2
      tabPanel("Jugadores Similares", 
           fluidRow(
             valueBoxOutput(width = 4, "info_box_sim"), 
             box(width = 8, tableOutput("card_info_player_simil"))
           ),
           fluidRow(
             box( width = 4, uiOutput("lista_jugadores_similares"),  DTOutput("similitud_players")),
             
             box(width = 8, plotOutput("simil_grafico"))
           )
       ),
      
      # Panel 3
      tabPanel("Información de la app",
           includeMarkdown("info_app.md")
       )
    ),
  )
)
