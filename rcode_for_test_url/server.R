# Contributed by Joe Cheng, February 2013
# Requires googleVis version 0.4.0 and shiny 0.4.0 or higher
# server.R
library(googleVis)
library(shiny)
library(RCurl)

metric_data <- function(session){
  query <- parseQueryString(session$clientData$url_search)
  apikey = query$apikey
  secret = query$secret
  owner = query$owner
  apikey=paste("apikey=",apikey,sep="")
  secret=paste("secret=",secret,sep="")
  owner=paste("owner=",owner,sep="")
  base_url = "http://server_ip:5000/listmetrics?"
  param = paste(apikey,secret,owner,sep="&")
  request_url = paste(base_url,param,sep="")
  result = getURL(request_url)
  result_df <- get_df_from_url_param(result)
  result_df
}

shinyServer(function(input, output, session) {
  
  metric_data_df <- reactive({
    metric_data(session)
  })
  
  datasetInput <- reactive({
    rock
  })
  
  output$view <- renderGvis({
    return(gvisScatterChart(datasetInput()))
  })
  
  # Return the components of the URL in a string:
  output$urlText <- renderText({
    paste(sep = "",
          "protocol: ", session$clientData$url_protocol, "\n",
          "hostname: ", session$clientData$url_hostname, "\n",
          "pathname: ", session$clientData$url_pathname, "\n",
          "port: ",     session$clientData$url_port,     "\n",
          "search: ",   session$clientData$url_search,   "\n"
    )
  })
  
  # Parse the GET query string
  output$queryText <- renderText({
    query <- parseQueryString(session$clientData$url_search)
    
    # Return a string with key-value pairs
    result=paste("apikey=",query$apikey,", secret=",query$secret,sep="")
    result
  })
  
  output$summary <- renderPrint({
    data <- metric_data_df()
    summary(data)
  })
  
  output$table <- renderDataTable({
    data <- metric_data_df()
    data
  })  
  
  output$namepaceSelector <- renderUI({
    data <- metric_data_df()
    selectInput("namespace", "Choose NameSpace", 
                choices = c('Not Selected',as.character(unique(data$namespace))))
  })
  
  output$dimensionSelector <- renderUI({
    if(is.null(input$namespace))return()
    data <- metric_data_df()
    data_namespace <- input$namespace
    conditionalPanel(condition = "input.namespace != 'Not Selected'",
                     selectInput("dimension", "Select Dimension Name", c('Not Selected',as.character(unique(subset(data,namespace==data_namespace)$dimensions.name)),selected=NULL))
    )
  })
  
  output$dimensionvalueSelector <- renderUI({
    if(is.null(input$namespace))return()
    data <- metric_data_df()
    data_namespace <- input$namespace
    data_dimension <- input$dimension
    conditionalPanel(condition = "input.dimension != 'Not Selected'",
                     selectInput("dimension_value", "Select Dimension Value", c('Not Selected',as.character(unique(subset(data,(namespace==data_namespace&dimensions.name==data_dimension))$dimensions.value)),selected=NULL))
    )
  })
  
  output$metricSelector <- renderUI({
    if(is.null(input$namespace))return()
    data <- metric_data_df()
    data_namespace <- input$namespace
    data_dimension <- input$dimension
    data_dimension_value <- input$dimension_value
    conditionalPanel(condition = "input.dimension_value != 'Not Selected'",
                     selectInput("metricname", "Select Metric Name", c('Not Selected',as.character(unique(subset(data,(namespace==data_namespace&dimensions.name==data_dimension&dimensions.value==data_dimension_value))$metricname)),selected=NULL))
    )
  })  
  
  output$testText <- renderText({
    # dependent on goButton
    input$goButton
    # isolate dependency on DropDown Selection
    # return text only if you click goButton
    isolate({
      query <- parseQueryString(session$clientData$url_search)
      apikey = query$apikey
      secret = query$secret
      param = ""
      namespace = paste("namespace=",input$namespace,sep="")
      dimension_name = paste("dimension_name=",input$dimension,sep="")
      dimension_value = paste("dimension_value=",input$dimension_value,sep="")
      metricname = paste("metricname=",input$metricname,sep="")
      date_str = as.character(input$dateRange)
      starttime=paste(date_str[1],"T00:00:00.000",sep="")
      starttime=paste("starttime=",starttime,sep="")
      endtime=paste(date_str[2],"T23:00:00.000",sep="")
      endtime=paste("endtime=",endtime,sep="")
      apikey=paste("apikey=",apikey,sep="")
      secret=paste("secret=",secret,sep="")
      owner=paste("owner=",owner,sep="")
      base_url = "http://server_ip:5000/getmetricdata?"
      param = paste(namespace,dimension_name,dimension_value,metricname,starttime,endtime,apikey,secret,owner,sep="&")
      
      param
      request_url = paste(base_url,param,sep="")
      result = getURL(request_url)
      result
    })
  })
  
  output$chart <- renderGvis({
      # dependent on goButton
      input$goButton
      # isolate dependency on DropDown Selection
      # return text only if you click goButton
      isolate({
        query <- parseQueryString(session$clientData$url_search)
        apikey = query$apikey
        secret = query$secret
	owner = query$owner
        param = ""
        namespace = paste("namespace=",input$namespace,sep="")
        dimension_name = paste("dimension_name=",input$dimension,sep="")
        dimension_value = paste("dimension_value=",input$dimension_value,sep="")
        metricname = paste("metricname=",input$metricname,sep="")
        date_str = as.character(input$dateRange)
        starttime=paste(date_str[1],"T00:00:00.000",sep="")
        starttime=paste("starttime=",starttime,sep="")
        endtime=paste(date_str[2],"T23:00:00.000",sep="")
        endtime=paste("endtime=",endtime,sep="")
        apikey=paste("apikey=",apikey,sep="")
        secret=paste("secret=",secret,sep="")
        owner=paste("owner=",owner,sep="")
        base_url = "http://server_ip:5000/getmetricdata?"
        param = paste(namespace,dimension_name,dimension_value,metricname,starttime,endtime,apikey,secret,owner,sep="&")
        request_url = paste(base_url,param,sep="")
        result = getURL(request_url)
        result_df <- get_df_from_metric_url_param(result)
        result_df$timestamp <- as.character(result_df$timestamp)
        result_df$sum <- as.numeric(as.character(result_df$sum))
        result_df$average <- as.numeric(as.character(result_df$average))
        result_df$maximum <- as.numeric(as.character(result_df$maximum))
        result_df$minimum <- as.numeric(as.character(result_df$minimum))
        result_df$samplecount <- as.numeric(as.character(result_df$samplecount))
        result_df <- cbind(result_df,strptime(paste(strsplit(result_df$timestamp,'T')[[1]][1],strsplit(result_df$timestamp,'T')[[1]][2]),"%Y-%m-%d %H:%M:%S"))
        names(result_df)[length(names(result_df))] <- c("date")
        
        gvisLineChart(result_df,xvar="timestamp",yvar=c("maximum","average","minimum"),options=list(pointSize=2))
      })
  })

output$chart_sample <- renderGvis({
  # dependent on goButton
  input$goButton
  # isolate dependency on DropDown Selection
  # return text only if you click goButton
  isolate({
    query <- parseQueryString(session$clientData$url_search)
    apikey = query$apikey
    secret = query$secret
    owner = query$owner
    param = ""
    namespace = paste("namespace=",input$namespace,sep="")
    dimension_name = paste("dimension_name=",input$dimension,sep="")
    dimension_value = paste("dimension_value=",input$dimension_value,sep="")
    metricname = paste("metricname=",input$metricname,sep="")
    date_str = as.character(input$dateRange)
    starttime=paste(date_str[1],"T00:00:00.000",sep="")
    starttime=paste("starttime=",starttime,sep="")
    endtime=paste(date_str[2],"T23:00:00.000",sep="")
    endtime=paste("endtime=",endtime,sep="")
    apikey=paste("apikey=",apikey,sep="")
    secret=paste("secret=",secret,sep="")
    owner=paste("owner=",owner,sep="")
    base_url = "http://server_ip:5000/getmetricdata?"
    param = paste(namespace,dimension_name,dimension_value,metricname,starttime,endtime,apikey,secret,owner,sep="&")
    request_url = paste(base_url,param,sep="")
    result = getURL(request_url)
    result_df <- get_df_from_metric_url_param(result)
    result_df$timestamp <- as.character(result_df$timestamp)
    
    result_df$samplecount <- as.numeric(as.character(result_df$samplecount))
    result_df <- cbind(result_df,strptime(paste(strsplit(result_df$timestamp,'T')[[1]][1],strsplit(result_df$timestamp,'T')[[1]][2]),"%Y-%m-%d %H:%M:%S"))
    names(result_df)[length(names(result_df))] <- c("date")
    
    gvisLineChart(result_df,xvar="timestamp",yvar=c("samplecount"),options=list(pointSize=2))
   })
  })

  output$chartData <- renderDataTable({
    # dependent on goButton
    input$goButton
    # isolate dependency on DropDown Selection
    # return text only if you click goButton
    isolate({
      query <- parseQueryString(session$clientData$url_search)
      apikey = query$apikey
      secret = query$secret
      owner = query$owner
      param = ""
      namespace = paste("namespace=",input$namespace,sep="")
      dimension_name = paste("dimension_name=",input$dimension,sep="")
      dimension_value = paste("dimension_value=",input$dimension_value,sep="")
      metricname = paste("metricname=",input$metricname,sep="")
      date_str = as.character(input$dateRange)
      starttime=paste(date_str[1],"T00:00:00.000",sep="")
      starttime=paste("starttime=",starttime,sep="")
      endtime=paste(date_str[2],"T23:00:00.000",sep="")
      endtime=paste("endtime=",endtime,sep="")
      apikey=paste("apikey=",apikey,sep="")
      secret=paste("secret=",secret,sep="")
      owner=paste("owner=",owner,sep="")	
      base_url = "http://server_ip:5000/getmetricdata?"
      param = paste(namespace,dimension_name,dimension_value,metricname,starttime,endtime,apikey,secret,owner,sep="&")
      request_url = paste(base_url,param,sep="")
      result = getURL(request_url)
      result_df <- get_df_from_metric_url_param(result)
      result_df$timestamp <- as.character(result_df$timestamp)
      result_df$sum <- as.numeric(as.character(result_df$sum))
      result_df$average <- as.numeric(as.character(result_df$average))
      result_df$maximum <- as.numeric(as.character(result_df$maximum))
      result_df$minimum <- as.numeric(as.character(result_df$minimum))
      result_df <- cbind(result_df,strptime(paste(strsplit(result_df$timestamp,'T')[[1]][1],strsplit(result_df$timestamp,'T')[[1]][2]),"%Y-%m-%d %H:%M:%S"))
      names(result_df)[length(names(result_df))] <- c("date")
      
      result_df
    })
  })
})
