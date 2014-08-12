library(shiny)
library(shinyIncubator)
library(googleVis)
suppressPackageStartupMessages(library(googleVis))

shinyServer(function(input, output, session) {
  get_input = reactive({
    withProgress(session, {
      setProgress(message = 'Collecting tweets...')
      get_tl()
    })
  })
  
  output$tl_table = renderGvis({
    gvisTable(get_input(), options = list(allowHtml = T, height = '600', width = '1200'))
  })
})