# Relection on Milestone 3

## Thoughts on developing dashboard in R rather than python

- Syntax differences between R and python when creating the dashboard took a while to get used to.

- We found RStudio a more cumberbersome IDE to work with as opposed to Visual Studio Code.

- Few interactivity features were automatically enabled in ggplotly which had to be separately coded when we used python and Altair

- The heatmap created using ggplot looked better than that created in python.

- Deployment using R took much longer than python since, everytime we update our code, we need to wait for approximately 15 minutes for the building process to be completed. Also, we needed to use docker when deploying using R (this wasnt required in python). Deployment using python was much more straight-forward.

## Changes made based on TA and Instructor feedback

We received feedback from the TA and also Joel, and were able to work on some of it in this milestone i.e. Milestone 3 (documented below). 

- Format line plots axis for year periods (as per TA and Joel's feedback)

- Change heatmap to square tiles from the previously used rectangular tiles

- Change default genres to present a more neat scenario

- Put the two line-plots next to each other

The remaining updates/improvements will be made during week 4.

## Future improvements/updates

- Create a common legend for both line plots

- Use a banner rather than just plain text for the title of the dashboard

- Explore downsampling or lowess to streamline plots

- Provide link to source of the data