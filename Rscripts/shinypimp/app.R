library(markdown)

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
    sidebarPanel(h4("This is the PiMPCraft file uploader."),
                 "Data uploaded only be available to the player with the specified username, so ensure it is entered correctly.",
                 br(), br(),
                 "After uploading your data, you can view it by connecting to the Minecraft server located on the same host as this page.",
                 br(), br(),
                 "The PiMPCraft README is included on this page. Full documentation and source code are available on ",
                 a(href = 'http://example.com', 'GitHub'),
                 ".",
                 br(), br(),
                 includeMarkdown('../../servermessage.md')
    ),
    mainPanel(p("Select a file to be uploaded, then enter your Minecraft player name and a memorable file identifier and click Submit."),
              fileInput("fileDetails", label = "File"),
              textInput("text1", label = "Minecraft player name"),
              textInput("text2", label = "Data file alias"),
              actionButton("act","Submit!"),
              tableOutput("fdout"),
              textOutput("verifier"),
              textOutput("infoOut"),
              hr(style="color: black;"),
              includeMarkdown('../../README.md')
    )
  )
)

shinyApp(ui = ui, server = server)
