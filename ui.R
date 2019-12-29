#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(dplyr)

# Define UI for application that draws a histogram
shinyUI(navbarPage("datscienceproject",
  
  # Application title
  tabPanel("nuage de point",
           
  
  # Sidebar with a slider input for number of bins 
  sidebarLayout(
    sidebarPanel(
      checkboxGroupInput("idtypemoto", "Type de moto:",
                         c("Custom" = "Custom",
                           "Quad" = "Quad",
                           "Roadster" = "Roadster",
                           "Routière / GT" = "Routière / GT",
                           "Scooter" = "Scooter",
                           "Side-car / Trike" = "Side-car / Trike",
                           "Sportive" = "Sportive",
                           "Tout terrain (Trial,  Enduro, Cross)" = "Tout terrain (Trial,  Enduro, Cross)",
                           "Trail / Supermotard" = "Trail / Supermotard"
                           )),
      sliderInput("age", "slider age :", min = 18, max = 90, value = c(18,90)),
      
    ),
    mainPanel(
       plotOutput("alexis")
    )
  )
  ),
  tabPanel("justine",
           sidebarLayout(
             sidebarPanel(
               sliderInput("age", "slider age :", min = 18, max = 90, value = c(18,90)),
               
             ),
             mainPanel(
               plotOutput("justine")
             )
           )
           
           
           
           
           
           ),
  tabPanel("temil"),
  tabPanel("Matt")
))
