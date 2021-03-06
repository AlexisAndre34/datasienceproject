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
library(FactoMineR)

Segment_2019 <- read_excel("Segment-2019.xlsx")
Qualif_2019 <- read_excel("Qualif 2019.xlsx")

dataProject <- left_join(Qualif_2019,Segment_2019, by="IDENTIFIANT")

ages2019 <- floor(age_calc(as.Date(dataProject$'DATE DE NAISSANCE.x'),Sys.Date(), units = "years"))

dataProject <- cbind(dataProject,ages2019)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  
  output$temil <- renderPlot({
    tranche <- cut(ages2019, c(0, 20, 40, 60, 80, 100))
    afc <- data.frame(segments=dataProject$SEGMENT,tranche=tranche)
    T=xtabs(~segments+tranche,afc)
    CA(T)
  })
  
  output$Matt2 <- renderPlot({
    
    if (is.null(input$typemoto2)){
      moto <- dataProject
    }
    else{
      moto <- dataProject %>% dplyr::filter(dataProject$SEGMENT %in% input$typemoto2)
    }
    
    situation <- moto$`SITFAM`
    
    situation <- case_when(
      situation == "En couple sans enfant"| situation =="En couple avec enfant(s)" ~ "En couple",
      situation == "Seul(e) sans enfant"| situation =="Seul(e) avec enfants" ~ "Celibataire",
      TRUE ~ "Autres"
    )
    
    situation <- cbind(situation,moto$`SEGMENT`)
    
    df3<-data.frame(
      situation = situation[,1],
      modele = situation[,2] 
    )
    
    bp3<-ggplot(df3) + geom_bar(aes(x=situation,y=modele,fill=modele),stat="identity")
    bp3
  })
  
  output$Quantiles <- renderPlot({
    
    if (is.null(input$typemoto3)){
      moto <- dataProject
      ages <- floor(age_calc(as.Date(moto$`DATE DE NAISSANCE`),Sys.Date(), units = "years"))
    }
    else{
      moto <- dataProject %>% dplyr::filter(dataProject$SEGMENT %in% input$typemoto3)
      ages <- floor(age_calc(as.Date(moto$`DATE DE NAISSANCE`),Sys.Date(), units = "years"))
    }
    
    
    ages <- case_when(
      ages < 39  ~ "0 - 38",
      ages > 38 & ages < 49 ~ "38 - 48",
      ages > 48 & ages < 58 ~ "48 - 57",
      ages > 57 ~ "57 - 95"
    )
    
    
    ageCompare <- cbind(ages,moto$`SEGMENT`)
    
    
    df6<-data.frame(
      age = ageCompare[,1],
      modele = ageCompare[,2] 
    )
    
    
    bp6<-ggplot(df6) + geom_bar(aes(x=age,y=fct_infreq(modele),fill=modele),stat="identity")
    bp6
  })
  
  
})
  
  
  output$alexis <- renderPlot({
   moto <- dataProject %>% dplyr::filter(dataProject$SEGMENT %in% input$idtypemoto)
   age_scale <- as.numeric(input$age)
   if (is.null(input$idtypemoto)){
     ggplot(data = dataProject, aes(x = IDENTIFIANT, y = ages2019, color = SEGMENT)) + 
       geom_point(aes(shape = SEGMENT))+
       ylim(age_scale[1], age_scale[2]) +
       labs(title = "type de moto en fonction de l'indivu et de son age", x = "Identifant", y = "age")
   }
   else{
     ggplot(data = moto, aes(x = IDENTIFIANT, y = ages2019, color = SEGMENT)) + 
       geom_point(aes(shape = SEGMENT)) +
       ylim(age_scale[1], age_scale[2])
   }
   
   
  })
  
  output$justine <- renderPlot({
    observe({
      age_scale <- as.numeric(input$age)
    })
   
    
    #Data frame avec l'age et la categorie de moto 
    df <- data.frame(
      group = ages2019,
      value = c(dataProject$'SEGMENT')
    )
  
    
   
    
   
    select_tranche <- filter(df, group >= as.numeric(input$age1[1]) & group <= as.numeric(input$age1[2]))

    #Data frame avec l'age compris entre des bornes
    
  
    
    
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
  


