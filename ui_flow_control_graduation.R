# UPDATE !!!!!!!!!!!!!!!
# Now we can treat graduation as standalone module
# Hence, we created some new checkers for graduate functions
# Also, a new graduation method - graduate_time() was added
# It graduates data across time, rather than age
# This was done because our previous graduation functions are heavily
# optimized towards working with age. Here are some examples.

# We begin with age graduation
# This part remains unchanged, so skip below
devtools::load_all()
library(dplyr)
data_in <- readr::read_csv(system.file("extdata",
                                       "abridged_hmd_spain.csv.gz",
                                       package="ODAPbackend"))

# standard checks run before doing the thing.
initial_data_checks <- check_upper(data = data_in, module = c("generic"))
initial_data_checks


head(data_in) # has .id column

output <- smooth_flexible(data_in,
                variable = "Deaths", # user specifies this
                age_out = "single", # always use this: not a user choice
                fine_method = "sprague", # user specifies from list (see below),
                rough_method = "none", # always use this: not a user choice
                constrain_infants = TRUE, # in case abridged age 0 should be maintained as-is
                Sex = "t", # If this is given as columnin the data, then it's detected. 
                           # Otherwise user should specify. 
                by_args = NULL, # can be ignored if .id present; don't include Sex here.
                               # in ui this is handled earlier in group definitions
                i18n = NULL # ui arg
                )


output$data_out # valid output

# figure separate for each .id
print(output$figures[[1]]$figure)
args(smooth_flexible)

# user-specified arguments:
# data_in, incoming data
# variable: which count variable do we graduate?
# method: graduation method. This arg is called fine_method in smooth_flexible(), 
#         but here we can call it 'method', and pass that to fine_method. 
#         Options include: "auto", "none", "sprague", "beers(ord)", 
#                          "beers(mod)", "grabill", "pclm", "mono", "uniform"

# constrain_infants = TRUE; only relevant if incoming data in abridged
# Sex = "t": only ask if method = "auto" AND there is no Sex column in data_in; 
# user options "Male", "Female", "Total", function feeder values: "m","f","t", as elsewhere

# fixed arguments:
# age_out = "single" (by definition)
# rough_method = "none"
# by_args = NULL (.id created earlier)
# i18n handled by frontend.

# --------------------------------------------------------------- #
# Graduate time example
# prepare data to run example graduate time example
# NOTE: The data are not real. Just imaginary quantities
Year <- seq(1950, 2015, by = 5)
# population exposure (millions, slowly increasing)
Exposure <- round(seq(45e6, 70e6, length.out = length(Year)))
# mortality rate declining from ~0.012 to ~0.009
mx <- seq(0.012, 0.009, length.out = length(Year))
# deaths
Deaths <- round(Exposure * mx)
df <- data.frame(
  Year = Year,
  Deaths = Deaths,
  Exposure = Exposure
)

# I have prepared a checker called check_data_graduate_time()
# lets run it first
# The arguments are data (a dataframe with our columns)
# X - this is the time variable name, like Year, time, x, anything
# Y - the variable that we plan to gradute Deaths, Exposures, etc.
# It will return a stacked dataframe with checks for each of the .id
# like other check function do check, message, pass, .id
check_inputs <- check_upper(data = data_in, module = c("graduate_time"), 
                            X = "Year",
                            Y = "Deaths")
# all passed
check_inputs

# so now we can use the graduate function
# Note the arguments they are similar to those of other gradutae functions
# data_in is clear, X and Y are the same as in cheker
# now, we also have a graduation method and timeInt
# timeInt indicates what is the initial time interval like 5, 10 year
# e.g. 2010-2015
# function will graduate to single time intervals
# NOTE if the method is pclm user can also provide an offset
# to aid the graduation. by default is NULL
output1 <- graduate_time(
  data_in = df,
  method = "pclm",
  X = "Year",
  Y = "Deaths",
  timeInt = 5,
  offset = NULL
  )

# the output is a neat dataframe with all the results
# in our case it is graduated Deaths by single Year and .id
# no offset was set
output1

# here to no offset is needed
output2 <- graduate_time(
  data_in = df,
  method = "uniform",
  X = "Year",
  Y = "Deaths",
  timeInt = 5
)

# final example is pclm with offset. in this case imaginable exposures
output3 <- graduate_time(
  data_in = df,
  method = "pclm",
  X = "Year",
  Y = "Deaths",
  timeInt = 5,
  offset = "Exposure"
)

# neat result
output3
