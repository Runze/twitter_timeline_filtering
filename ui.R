library(shiny)
library(shinyIncubator)

shinyUI(fluidPage(theme='bootstrap.min.css',
  tags$style(type='text/css',
             'label {font-size: 12px;}',
             '.recalculating {opacity: 1.0;}'
  ),
  
  tags$h2("Filtered twitter timeline"),
  
  progressInit(),
  htmlOutput('tl_table'),
  
  p(tags$a(href = 'http://www.runzemc.com', 'www.runzemc.com'))
))