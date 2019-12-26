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

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  
  #colnames(dataProject) <- make.unique(names(dataProject))
  
  output$distPlot <- renderPlot({
   moto <- dataProject %>% dplyr::filter(dataProject$SEGMENT %in% input$idtypemoto)
   
   
   ggplot(moto,aes(dataProject$IDENTIFIANT, dataProject$AGE)) + 
     geom_point()
  })
  
})
