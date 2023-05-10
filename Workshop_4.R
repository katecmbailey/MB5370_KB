### Data Mangement - Workshop 4 ###

---------------------------------------------------------------

## Tibbles ##

# Tibble is a dataframe 

## Setting up the code ##

library(tidyverse) # Tibble is in this package


vignette("tibble") #Information about tibble

# To convert regular data frames into tibbles you can use as_tibble():

iris # look at iris
str(iris) # check it out - what type is it? how many rows?

as_tibble(iris)

# Example of how to make columns 

tibble(
  x = 1:5, 
  y = 1, 
  z = x ^ 2 + y ) # call new variables to produce new column values!

## Tribbles ##

# (tribble()) is basically for one purpose: to help you do data entry directly in your script. The column headings are defined by formulas (they start with ~), and each data entry is put in a column, separated by commas.

as_tibble(iris)

# Let’s have a look - notice this tibble is telling us we have a  data-time column (dttm), a date column, an integer, a doublem and a character. All without having to call an extra function to look at it. 


tibble(
  a = lubridate::now() + runif(1e3) * 86400,
  b = lubridate::today() + runif(1e3) * 30,
  c = 1:1e3,
  d = runif(1e3),
  e = sample(letters, 1e3, replace = TRUE)
)

# You can use print() to designate the number of rows (n) and display width. (width = Inf #displays every column).


## Example ##

install.packages("nycflights13")
library(nycflights13)
nycflights13::flights %>% 
  print(n = 10, width = Inf)

# : if more than n rows, print only m rows. 
# Use options(tibble.print_min = Inf) to always show all rows.
# Use options(tibble.width = Inf) to always print all columns, regardless of the width of the screen.

# You set global options for your R session like this: options(tibble.width = Inf)

# We can use a dollar sign ($) to extract a full column of data (by name), or the simple double bracket to pull out an exact row of data (by row position).

# Extract by name = df$x

# Then df[["x"]] to extract a value 

## How can I import data? ##

# read_csv() reads comma delimited files, read_csv2() reads semicolon separated files (common in countries where , is used as the decimal place), read_tsv() reads tab delimited files, and read_delim() reads in files with any delimiter.

# if you have metadata at the top of your file, you might want to skip these lines using skip = n where n is the number of lines you want to skip over. 
# Alternatively, use comment = '#' to will drop all lines starting with a “#” or whatever character you designate.

read_csv("The first line of metadata
  The second line of metadata
  x,y,z
  1,2,3", skip = 2)


# if your data does not contain column names use col_names = FALSE to tell read_csv() not to treat the first row as headings but to instead label them sequentially from X1 to Xn.

read_csv("1,2,3\n4,5,6", col_names = FALSE)

# Here ("\n" is simply a shortcut for adding a new line. This is a common ‘break’ in programming. 
      
# You can pass col_names a character vector to be used as the column names:
  
read_csv("1,2,3\n4,5,6", col_names = c("x", "y", "z"))

---------------------------------------------------------------

## Tidy data ##

# RULES 
# 1. Each variable must have its own column.
# 2. Each observation must have its own row.
# 3. Each value must have its own cell

#  %>% = pipe operator 

# Examples

# Compute rate per 10,000
table1 %>% 
  mutate(rate = cases / population * 10000)

# Compute cases per year
table1 %>% 
  count(year, wt = cases)

# Visualise changes over time
library(ggplot2)
ggplot(table1, aes(year, cases)) + 
  geom_line(aes(group = country), colour = "grey50") + 
  geom_point(aes(colour = country))

---------------------------------------------------------------
  
## Spreading and gathering data tables ##

# Common problems 

# One variable is spread across multiple columns
# One observation is scattered across multiple rows

#To fix these we will explore the use of two functions in tidyr: 

#pivot_longer()
#pivot_wider()

# For example 

table4b %>% 
  pivot_longer(c(`1999`, `2000`), names_to = "year", values_to = "population")


table2 %>%
  pivot_wider(names_from = type, values_from = count)



# Separate() will split values wherever it sees a non-alphanumeric character (i.e. a character that isn’t a number or letter).

# For example 

table3 %>% 
  separate(rate, into = c("cases", "population"), sep = "/")


# Both cases and population are listed as character types. This is a default of using separate(). However, since the values in those columns are actually numbers, we want to ask separate() to convert them to better types using convert = TRUE

# For example 

table3 %>% 
  separate(rate, into = c("cases", "population"), convert = TRUE)

table3 %>% 
  separate(year, into = c("century", "year"), sep = 2) # separate the last two digits of each year

# unite() to combine multiple columns into a single column


# Example

table5 %>% 
  unite(new, century, year, sep = "")


## Handling missing values ##

# NA = Explict missingvalues

# For example, we can make the implicit missing value explicit by putting years in the column

stocks %>% 
  pivot_wider(names_from = year, values_from = return)


# Because these explicit missing values may not be important in other representations of the data, you can set values_drop_na = TRUE in pivot_longer() to turn explicit missing values implicit. 
# This makes those missing values that are probably not supposed to be missing now a valid row of data in your data frame.

# Example 

stocks %>% 
  pivot_wider(names_from = year, values_from = return) %>% 
  pivot_longer(
    cols = c(`2015`, `2016`), 
    names_to = "year", 
    values_to = "return", 
    values_drop_na = TRUE
  )

# The fill() function can be used to fill in missing values that were meant to be carried forward in the data entry process. It can take columns with missing values and carry the last observation forward (replace them with the most recent non-missing value).

---------------------------------------------------------------

## Learning relational data ##

# dplyr is a package focused on the grammar of data manipulation. It’s a package specialised for doing data analysis. 

# The three families of verbs designed to work with relational data are:
# Mutating joins - add new variables to one dataframe from matching observations in another
# Filtering joins - filter observations from one data frame based on whether or not they match an observation in the other table
# Set operations - treat observations as if they are set elements

---------------------------------------------------------------

## Joining datasets ##
  
# 2 Keys 
  
# A primary key uniquely identifies an observation in its own table. 
# A foreign key uniquely identifies an observation in another table.

# If a table lacks a primary key, it’s sometimes useful to add one with mutate() and row_number(). That makes it easier to match observations if you’ve done some filtering and want to check back in with the original data. This is called a surrogate key.

---------------------------------------------------------------

## Mutating joins ##


# Join functions (like the base mutate()) add variables to the right side of your data table so sometimes you’ll need to change the view of your screen to see them all (use tibble)

# Function leftjoin()
  
flights2 %>%
  select(-origin, -dest) %>% 
  left_join(airlines, by = "carrier") # this is the variable

# Mutating Join 

flights2 %>%
  select(-origin, -dest) %>% 
  mutate(name = airlines$name[match(carrier, airlines$carrier)]) # Variables in the match area


# inner join

# inner join is that unmatched rows are not included in the result.

x %>% 
  inner_join(y, by = "key")

# The other category of join is the outer join which keeps observations that appear in at least one of the tables. There are three types of outer joins:
# left_join() keeps all observations in x (we’ve seen this in our first example)  
# right_join() keeps all observations in y 
# full_join() keeps all observations in x and y

# The left join should be your default join, because it preserves the original observations even when there isn’t a match.


---------------------------------------------------------------

## Filtering Joins ##
  
#The two types of filtering joins are semi_join(x,y) and anti_join(x,y).
  
# semi_join(x,y) keeps all observations in x that have a match in y 

# anti_join(x,y) drops all the observations in x that have a match in y.

# For example 
  
  flights %>% 
  semi_join(top_dest)
  
# Anti-joins are the inverse of semi_joins in that they keep rows without matches. They are great for diagnosing mismatches in a dataset.

# For example 

flights %>%
  anti_join(planes, by = "tailnum") %>%
  count(tailnum, sort = TRUE)





