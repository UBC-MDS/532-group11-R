library(dash)
library(dashHtmlComponents)

app = Dash$new()
  
app$layout(htmlDiv('Alive and well'))

app$run_server(debug=T)

