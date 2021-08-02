# forecasting_pipeline_TESTING

Very first sketches of an automated forecasting pipeline to eventually be used in future scientific projects.
The current code:
  1) grabs the price of the Magic the Gathering card "Polluted Delta" from mtggoldfish.com via raw html page source
  2) conducts a few steps of command line txt processing to get a data frame for R
  3) cleans the price data over time in R
  4) fits a very simple random walk model in Stan
  5) projects the price (via the random walk) forward 200 days
  6) saves the plot
  
The next plan is to explore crom to get this whole thing automated even further
