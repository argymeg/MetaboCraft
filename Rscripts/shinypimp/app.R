library(markdown)

server <- function(input, output) {
  output$ex1data <- downloadHandler(
    filename = "example1.csv",
    content = function(file){
      file.copy("../../examples/example1.csv", file)
    }
  )
  output$ex1names <- downloadHandler(
    filename = "example1-filenames.txt",
    content = function(file){
      file.copy("../../examples/example1-filenames.txt", file)
    }
  )
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

              source("parsepeaks-ave.R", local = TRUE)
              output$verifier <- renderText('<span style="color:green">Done!</span>')
              output$infoOut <- renderText(paste('Your data can be accessed by player <span style="font-weight:bold">', playerName,
                                                 '</span> using the alias <span style="font-weight:bold">', alias, '</span>.', sep = ""))
            }, error = function(e){
              output$verifier <- renderText('<span style="color:red">Something went wrong! Please check that your submitted column names correspond to your submitted CSV file.</span>')
              output$infoOut <- renderText("")
            })
          }
        )
      }
      else{
        output$verifier <- renderText('<span style="color:red">Please upload a file first!</span>')
        output$infoOut <- renderText("")
      }
    }
  })
}

ui <- fluidPage(
  titlePanel("PiMPCraft Home"),
  sidebarLayout(position = "right",
    sidebarPanel(h4("This is the PiMPCraft file uploader."),
                 "Data uploaded will only be available to the player with the specified username, so ensure it is entered correctly.",
                 br(), br(),
                 "After uploading your data, you can view it by connecting to the Minecraft server located on the same host as this page.",
                 br(), br(),
                 HTML('The PiMPCraft README is included on this page (you might want to jump to the <a href="#the-client-side">client section</a>).
                      Full documentation and source code are available on <a href = "https://github.com/argymeg/PiMPCraft">GitHub</a>.'),
                 br(), br(),
                 h4("Example datasets"),
                 h5("Example 1"),
                 downloadLink("ex1data", label = "Download data"),
                 br(),
                 downloadLink("ex1names", label = "Download column names"),
                 br(), br(),
                 includeMarkdown('../../servermessage.md')
    ),
    mainPanel(p("Select a file to be uploaded, then enter your Minecraft player name and a memorable file identifier and click Submit."),
              fileInput("fileDetails", label = "File"),
              textInput("playerntext", label = "Minecraft player name"),
              textInput("aliastext", label = "Data file alias"),
              textInput("cond1coltext", label = "Column names for condition 1"),
              textInput("cond2coltext", label = "Column names for condition 2"),
              actionButton("act","Submit!", icon("upload"), style="color: white; background-color: black"),
              htmlOutput("verifier"),
              htmlOutput("infoOut"),
              hr(style="color: black;"),
              includeMarkdown('../../README.md')
    )
  )
)

shinyApp(ui = ui, server = server)
