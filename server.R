#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#
library(readxl)
library(shiny)
library(dplyr)
library(ggplot2)
library(eeptools)

Segment_2019 <- read_excel("Segment-2019.xlsx")
Qualif_2019 <- read_excel("Qualif 2019.xlsx")

dataProject <- left_join(Qualif_2019,Segment_2019, by="IDENTIFIANT")

ages2019 <- floor(age_calc(as.Date(dataProject$'DATE DE NAISSANCE.x'),Sys.Date(), units = "years"))

dataProject <- cbind(dataProject,ages2019)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  
  #colnames(dataProject) <- make.unique(names(dataProject))
  
  output$alexis <- renderPlot({
   moto <- dataProject %>% dplyr::filter(dataProject$SEGMENT %in% input$idtypemoto)
   age_scale <- as.numeric(input$age)
   if (is.null(input$idtypemoto)){
     ggplot(data = dataProject, aes(x = IDENTIFIANT, y = ages2019, color = SEGMENT)) + 
       geom_point(aes(shape = SEGMENT))
   }
   else{
     ggplot(data = moto, aes(x = IDENTIFIANT, y = ages2019, color = SEGMENT)) + 
       geom_point(aes(shape = SEGMENT)) +
       ylim(age_scale[1], age_scale[2])
   }
   
   
  })
  
})
