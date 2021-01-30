library(dash)
library(dashCoreComponents)
library(dashHtmlComponents)
library(dashBootstrapComponents)
library(tidyverse)
library(here)
library(plotly)
library(lubridate)
library(dashTable)



app <- Dash$new(external_stylesheets = dbcThemes$SANDSTONE)

### Data loading and cleaning

set_here('/home/yazan/ubc-mds/block_4/532/532-group11-R')
data_path <-
  paste0(here(), '/data/processed/processed_movie_data.csv')
data <-  read_csv(data_path)

data$release_date <- as.Date(data$release_date)
data$release_month <- month(data$release_month, label = TRUE)


app$callback(output('plot-heatmap', 'figure'),
             list(input('genres', 'value'),
                  input('years', 'value')),
             function(g, y) {
               filtered <- data %>%
                 filter(genres %in% g &
                          release_year >= y[1] &
                          release_year <= y[2])
               heatmap <- ggplot(filtered) +
                 aes(x = vote_average,
                     y = genres) +
                 #geom_bin2d(bins=11) +
                 stat_bin2d(aes(fill = after_stat(count)), binwidth = 1) +
                 coord_fixed(1) +
                 labs(x = 'Vote Average', y = 'Genre', fill = 'Count') +
                 theme_bw() +
                 theme(
                   panel.grid.major = element_blank(),
                   panel.grid.minor = element_blank(),
                   panel.border = element_blank()
                 )
               return(ggplotly(heatmap))
             })

app$callback(
  output('plot-budget-year', 'figure'),
  list(input('genres', 'value'),
       input('years', 'value')),
  plot_budget_year <- function(g, y) {
    filtered <- data %>%
      filter(genres %in% g &
               release_year >= y[1] & release_year <= y[2]) %>%
      group_by(release_year, genres) %>%
      summarise(mean_budget = mean(budget_adj))
    plot <- ggplot(data = filtered) +
      aes(
        x = release_year,
        y = mean_budget,
        group = genres,
        color = genres
      ) +
      geom_line() +
      scale_y_continuous(labels = scales::dollar) +
      labs(x = "Release Year", y = "Mean Budjet", color = "Genres")
    ggplotly(plot)
  }
)


app$callback(
  output('plot-profit-month', 'figure'),
  list(input('genres', 'value'),
       input('years', 'value')),
  plot_profit_month <- function(g, y) {
    filtered <- data %>%
      filter(genres %in% g &
               release_year >= y[1] & release_year <= y[2]) %>%
      group_by(release_month, genres) %>%
      summarise(med_profit = median(profit))
    plot <- ggplot(data = filtered) +
      aes(
        x = release_month,
        y = med_profit,
        group = genres,
        color = genres
      ) +
      geom_line() +
      scale_y_continuous(labels = scales::dollar) +
      labs(x = "Release Month", y = "Median Profit", color = "Genres")
    ggplotly(plot)
  }
)

app$callback(
  output('actors_table', 'data'),
  list(
    input('genres_drill', 'value'),
    input('years', 'value'),
    input('budget', 'value')
  ),
  generate_actor_table <- function(g, y, b) {
    filtered <- data %>%
      filter(genres == g &
               release_year >= y[1] & release_year <= y[2] &
               budget_adj >= b[1] & budget_adj <= b[2]) %>%
      select(cast) %>%
      mutate(actor = strsplit(cast, "\\|")) %>%
      unnest(actor) %>%
      group_by(actor) %>%
      tally() %>%
      arrange(desc(n)) %>%
      slice(1:5)
    return((filtered))
  }
)


app$callback(list(
  output('genres_drill', 'value'),
  output('genres_drill', 'options')
),
list(input('genres', 'value')),
update_genres <- function(genres) {
  options_value <- purrr::map(genres, function(genre)
    list(label = genre, value = genre))
  return(list(genres[[1]], options_value))
})


### BEGIN APP LAYOUT


app$layout(dbcContainer(list(
  htmlBr(),
  htmlH1("Movie Production Planner"),
  htmlBr(),
  dbcRow(list(
    dbcCol(
      list(
        htmlLabel("Years"),
        dccRangeSlider(
          id = "years",
          count = 1,
          step = 1,
          min = min(data$release_year),
          max = max(data$release_year),
          marks=list("1960" = "1960", "2015" ="2015"),
          value = c(2000, 2016),
          tooltip = list("always_visible" = FALSE, "placement" = "top")
        )
      ),
      md = 6,
      style = list("height" = "75px")
    ),
    dbcCol(
      list(
        htmlLabel("Genres"),
        dccDropdown(
          id = 'genres',
          options = purrr::map(unique(data$genres), function(genre)
            list(label = genre, value = genre)),
          value = list('Action', 'Drama', 'Adventure', 'Family', 'Animation'),
          multi = TRUE
        )
      ),
      md = 6,
      style = list("border" = "0px",
                   "border-radius" = "10px")
    )
  )),
  htmlBr(),
  ## MAIN PLOTS AREA
  dbcRow(list(dbcCol(
    list(### FIRST ROW OF PLOTS
      dbcRow(list(
        dbcCol(list(
          htmlBr(),
          htmlLabel(
            "Discover historical and recent budget trends",
            style = list("font-size" = 20)
          ),
          dccGraph(id = 'plot-budget-year')
        )),
        dbcCol(list(
          htmlBr(),
          htmlLabel("Plan your release month",
                    style = list("font-size" = 20)),
          dccGraph(id = 'plot-profit-month')
        ))
      )),
      htmlBr(),
      ### SECOND ROW OF PLOTS
      dbcRow(list(
        dbcCol(list (
          htmlBr(),
          htmlLabel("Identify most-liked genres", style = list("font-size" = 20)),
          dccGraph(id = 'plot-heatmap'),
          htmlBr()
        )),
        dbcCol(list(
          htmlBr(),
          htmlLabel("Find some potential actors",
                    style = list("font-size" = 20)),
          dbcRow(list(dbcCol(
            list(
              htmlLabel("1. Drill down on a specific genre"),
              dccDropdown(
                id = "genres_drill",
                multi = FALSE,
                style = list("width" = "200px")
              )
            )
          ))),
          dbcRow(list(dbcCol(
            list(
              htmlLabel("2. Narrow down your budget"),
              dccRangeSlider(
                id = "budget",
                count = 1,
                step = 1,
                min = min(data$budget_adj),
                max = max(data$budget_adj),
                value = list(0, 425000000),
                tooltip = list("always_visible" = FALSE, "placement" = "top")
              )
            )
          ))),
          dbcRow(list(dbcCol(list(
            htmlLabel("3. Select an actor!")
          )))),
          dbcRow(list(dbcCol(
            list(dashDataTable(
              id = 'actors_table',
              columns = list(
                list(id = 'actor',
                     name = 'Actor'),
                list(id = 'n',
                     name = '# of matching movies they starred in')
              )
            ))
          )))
        ))
        
      )))
  )))
)))



app$run_server(debug = T)
