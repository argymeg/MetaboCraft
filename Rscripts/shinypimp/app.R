library(markdown)

server <- function(input, output) {
  observe({
    input$act
    if(input$act > 0){
      if(isolate(!is.null(input$fileDetails$name))){
        withProgress(
          message = "Processing file...", {
            tryCatch({
              playerName <- isolate(input$playerntext)
              alias <- isolate(input$aliastext)
              userdataSource <- isolate(input$fileDetails$datapath)
              cond1colsIn <- isolate(input$cond1coltext)
              cond2colsIn <- isolate(input$cond2coltext)
              
              source("../parsepeaks-ave.R", local = TRUE)
              output$verifier <- renderText('<span style="color:green">Done!</span>')
              output$infoOut <- renderText(paste("Your PiMPCraft file identifier is: ", playerName, "-", alias, sep = ""))
            }, error = function(e){
              output$verifier <- renderText('<span style="color:red">Something went wrong! Please check that your submitted column names correspond to your submitted CSV file.</span>')
              output$infoOut <- renderText("")
            })
          }
        )
      }
      else{
        output$verifier <- renderText("Please upload a file first!")
        output$infoOut <- renderText("")
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
              textInput("playerntext", label = "Minecraft player name"),
              textInput("aliastext", label = "Data file alias"),
              textInput("cond1coltext", label = "Column names for condition 1"),
              textInput("cond2coltext", label = "Column names for condition 2"),
              actionButton("act","Submit!"),
              tableOutput("fdout"),
              htmlOutput("verifier"),
              textOutput("infoOut"),
              hr(style="color: black;"),
              includeMarkdown('../../README.md')
    )
  )
)

shinyApp(ui = ui, server = server)
