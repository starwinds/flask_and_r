# ui.R


shinyUI(
  fluidPage(
    titlePanel("Metric Navigation"),
    tabsetPanel(
      tabPanel("Metric Scheme",
               #verbatimTextOutput("queryText"),
               h3("Summary"),
               verbatimTextOutput("summary"),
               h3("Data"),
               dataTableOutput(outputId="table")
      ),
      tabPanel("Metric Data",
               fluidRow(
                 column(4, wellPanel(
                   br(),
                   htmlOutput("namepaceSelector"),
                   htmlOutput("dimensionSelector"),
                   htmlOutput("dimensionvalueSelector"),
                   htmlOutput("metricSelector"),
                   dateRangeInput('dateRange',
                                  label = 'Date range input: yyyy-mm-dd',                                
                                  start = Sys.Date() - 1, end = Sys.Date()
                   ),
                   actionButton("goButton", "Go!")
                   #submitButton("Submit")
                 )),
                 column(6,
                        #plotOutput("plot1", width = 400, height = 300),
                        br(),
                        h4("Sample Count Graph"),
                        htmlOutput("chart_sample"),
                        
                        h4("Data Graph"),
                        htmlOutput("chart"),
                        
                        #verbatimTextOutput("chartData"),
                        h4("RawData"),
                        #verbatimTextOutput("testText")
                        dataTableOutput(outputId="chartData")
                 )
               )
      ),
      tabPanel("Sample Count",
               #verbatimTextOutput("queryText"),
               h3("Sample Count")
               
      )
    )
  )
)
