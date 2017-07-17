#library(shiny)

server <- function(input, output) {
  output$fdout <- renderTable(input$fileDetails) #Remove as soon as I'm sure of everything else!

  
  observe({
    input$act
    if(input$act > 0){
      if(isolate(!is.null(input$fileDetails$name))){
        playerName <- input$text1
        alias <- input$text2
        metadataSource <- input$fileDetails$datapath
        
        source("../autoProcessMetadata-global.R", local = TRUE)
        output$verifier <- renderText("Success!")
        output$infoOut <- renderText(isolate(paste("Your PiMPCraft file identifier is: ", playerName, "-", alias, sep = "")))
      }
      else{
        output$infoOut <- renderText("Upload a file first!")
      }
    }
  })
}

ui <- fluidPage(
  titlePanel("PiMPCraft Home"),
  sidebarLayout(position = "right",
    sidebarPanel(h1("info1"),
                 "detinfo1",
                 h2("info2"),
                 "detinfo2"
    ),
    mainPanel(p("Select a file to be uploaded, THEN enter your Minecraft player name and a memorable file identifier and click Submit."),
              fileInput("fileDetails", label = "File"),
              textInput("text1", label = "Minecraft player name"),
              textInput("text2", label = "Data file alias"),
              actionButton("act","Submit!"),
              tableOutput("fdout"),
              textOutput("verifier"),
              textOutput("infoOut")
    )
  )
)

shinyApp(ui = ui, server = server)
