library(dash)
library(dashCoreComponents)
library(dashHtmlComponents)
library(dashBootstrapComponents)
library(ggplot2)
library(plotly)
library(tidyverse)

data <- readr::read_csv(here::here('data/processed', 'processed_movie_data.csv'))

app <- Dash$new(external_stylesheets = dbcThemes$BOOTSTRAP)

app$layout(
  dbcContainer(
    list(
      dccGraph(id='plot-area'),
      htmlBr(),
      dccRangeSlider(
        id='years',
        count=1,
        step=1,
        min=min(data$release_year),
        max=max(data$release_year),
        value=list(2000,2015))
    )
  )
)


app$callback(
  output('plot-area', 'figure'),
  list(input('years', 'value')),
  function(years) {
    heatmap <- data %>% 
      filter(release_year>=years[1] & release_year<=years[2]) %>% 
      ggplot() + 
      aes(x = vote_average,
          y = genres) +
      geom_bin2d() +
      labs(title='Vote Average by Genre', x='Genres', y='Vote Average')
    ggplotly(heatmap)
  }
)


app$run_server(debug = T)

