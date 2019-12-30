
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

Qualif_2019 <- read_excel("C:/Users/haasm/Downloads/Qualif 2019.xlsx")

Segment_2019 <- read_excel("C:/Users/haasm/Downloads/Segment-2019 (2).xlsx")

dataProject <- left_join(Qualif_2019,Segment_2019, by="IDENTIFIANT")

ages2019 <- floor(age_calc(as.Date(dataProject$`DATE DE NAISSANCE`),Sys.Date(), units = "years"))

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
    
    if (is.null(input$typemoto)){
      moto <- dataProject
    }
    else{
      moto <- dataProject %>% dplyr::filter(dataProject$SEGMENT %in% input$typemoto)
    }
    
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
