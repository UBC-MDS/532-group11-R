library(dash)
library(dashCoreComponents)
library(dashHtmlComponents)
library(dashBootstrapComponents)

app <- Dash$new(external_stylesheets = dbcThemes$BOOTSTRAP)



app$layout(dbcContainer(list(
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
          min = 1960,
          max = 2015,
          value = c(2000, 2016),
        )
      ),
      md = 6,
      style = list("border" = "0px",
                   "border-radius" = "10px")
    ),
    dbcCol(
      list(
        htmlLabel("Genres"),
        dccDropdown(
          id = 'genres',
          options = list(
            list(label = "New York City", value = "NYC"),
            list(label = "Montreal", value = "MTL"),
            list(label = "San Francisco", value = "SF")
          ),
          value = list('NYC', 'MTL'),
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
    list(## FIRST ROW OF PLOTS
      dbcRow(list(
        dbcCol(list (
          htmlBr(),
          htmlLabel("Identify most-liked genres", style = list("font-size" = 20))
        )),
        dbcCol(list(
          htmlBr(),
          htmlLabel(
            "Discover historical and recent budget trends",
            style = list("font-size" = 20)
          )
        ))
      )),
    dbcRow(list(dbcCol(
      list(htmlBr(),
           htmlLabel(
             "Find some potential actors",
             style = list("font-size" = 20)
           ))
    ),
    dbcCol(
      list(htmlBr(),
           htmlLabel(
             "Plan your release month",
             style = list("font-size" = 20)
           ))
    )))
  )))
))))



app$run_server(debug = T)
