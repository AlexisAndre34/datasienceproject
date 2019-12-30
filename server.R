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
       geom_point(aes(shape = SEGMENT))+
       ylim(age_scale[1], age_scale[2])
   }
   else{
     ggplot(data = moto, aes(x = IDENTIFIANT, y = ages2019, color = SEGMENT)) + 
       geom_point(aes(shape = SEGMENT)) +
       ylim(age_scale[1], age_scale[2])
   }
   
   
  })
  
  output$justine <- renderPlot({
    age_scale <- as.numeric(input$age)
    
   #Data frame avec l'age et la categorie de moto 
    df <- data.frame(
      group = ages2019,
      value = c(dataProject$'SEGMENT')
    )
    
    #Data frame avec l'age compris entre des bornes
    select_tranche<- filter(df, group >age_scale[1] & group <age_scale[2])
  
    
    #Data frame avec la frequence des moto en fonction de l'age donnee et de la moto
    dataframefreq<-as.data.frame(table(select_tranche))

    
    #Renommage des colonne
    df<-dataframefreq %>% 
      rename(
        NbFragment = Freq,
        Fragment = value
      )

    
    barplot(df$NbFragment, names.arg=df$Fragment, ylim=c(0,2000), ylab="Nombre de motos", xlab="Fragments")
    
    #GRAPHIQUE BIEN juste les legendes se chevauche
    ggplot(data=df, aes(x=Fragment, y=NbFragment,fill=Fragment)) +
      geom_bar(stat="identity") +
      geom_text(aes(label=NbFragment), vjust=1.6, color="white", size=3.5)+
      theme_minimal()
    
    
  })
  
  output$Matt <- renderPlot({
    
    moto <- dataProject %>% dplyr::filter(dataProject$SEGMENT %in% input$idtypemoto)
    
    csp <- moto$`CSP`
    status <- case_when(
      csp == "Cadres" ~ "Cadres",
      csp == "Employés" ~ "Employes",
      csp == "Etudiants" | csp =="En recherche d'emploi" ~ "Etudiant & Chomeurs",
      TRUE ~ "Autres"
    )
    
    status <- cbind(status,moto$`SEGMENT`)
    
    df4<-data.frame(
      status = status[,1],
      modele = status[,2] 
    )
    
    bp4<-ggplot(df4) + geom_bar(aes(x=status,y=modele,fill=modele),stat="identity") 
    bp4
  })
    

  
})
