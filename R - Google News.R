#-------------+
# Web Scraping|
#-------------+

# install packages
install.packages("rvest")
install.packages("stringr")
install.packages("lubridate")

# import packages
library("rvest")
library("stringr")
library("lubridate")

# change my language setting
Sys.setenv(LANG = "en")


## load and visualize the news
news_db <- read_html("https://news.google.com/rss/search?q=sports%20news%20today&hl=en-US&gl=US&ceid=US%3Aen")
str(news_db)

# extract html/xml elements
news_db %>% html_nodes("title")  #%>% is the "pipe
news_db %>% html_nodes("pubdate")

# make it "clean"
news_db %>% html_nodes("title") %>% html_text()

# create a news dataframe
headlines <- news_db %>% html_nodes("title") %>% html_text()
dates <- news_db %>% html_nodes("pubdate") %>% html_text()

# attention
length(headlines)
length(dates)

headlines
headlines <- headlines[-1] # now we removed the page headline that is not a "news"

# dataframe
news <- data.frame(headlines, dates)

## data treatment
# adjusting the date
news$dates <- gsub(",", "", news$dates)
news$dates <- gsub("GMT", "", news$dates)
news$dates[1]

str(news) # my dates are in chr

# adjusting the dates with lubridate
news$dates <- parse_date_time2(news$dates, orders = "dmyyHMS", tz = "GMT")
head(news)

## Simulating database atualization
news2 <- news
news2$headlines[1] <- "Cristiano Ronaldo decides to become Sporting CP manager"
news2$dates[1] <- parse_date_time2("Sun 31 May 2022 01:03:37", orders = "dmyyHMS", tz = "GMT")
head(news2)

# return only different headlines
diff_headlines <- subset(news2, !(headlines %in% news$headlines))
diff_headlines

# put the new headline into the initial database
news <- rbind(news, diff_headlines)
dim(news)

# create a csv file with your database
write.csv2(news, "news_db.csv", row.names = FALSE)

# ordering the database
news <- news[rev(order(news$dates)),]

## create a function
# clean workspace
rm(list = ls())

# function
get_gnews_data <- function(link) {
  news_db <- read_html(link)
  headlines <- news_db %>% html_nodes("title") %>% html_text()
  headlines <- headlines[-1]
  dates <- news_db %>% html_nodes("pubdate") %>% html_text()
  news <- data.frame(headlines, dates)
  news$dates <- gsub(",", "", news$dates)
  news$dates <- gsub("GMT", "", news$dates)
  news$dates <- parse_date_time2(news$dates, orders = "dmyyHMS", tz = "GMT")
  if(file.exists("news_db.csv"))
  {
    base <- read.csv("news_db.csv", stringsAsFactors = FALSE)
    diff_headlines <- subset(base, !(headlines %in% base$headlines))
    base <- rbind(base, diff_headlines)
    write.csv2(base, "news_db.csv", row.names = FALSE)
  }else{
    write.csv2(news, "news_db.csv", row.names = FALSE)
  }
  
}

link = "https://news.google.com/rss/search?q=sports%20news%20today&hl=en-US&gl=US&ceid=US%3Aen"

get_gnews_data(link)