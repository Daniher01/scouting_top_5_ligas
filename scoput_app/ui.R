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

data = read.csv("../data/players_p90.csv")



# Define UI for application that draws a histogram
dashboardPage(
  dashboardHeader(title = "Scouting Top 5 Ligas"),
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
  dashboardBody()
)
