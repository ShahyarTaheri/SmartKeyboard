
## Setup
# Data processing 
library(dplyr); library(data.table)
# Text proccessing libraries
library(tm);library(stringi);library(tidytext)
# Plotting libraries
library(ggplot2);library(wordcloud);library(ggwordcloud);
# Performance Optimization
library(parallel);library(doParallel)

jobcluster = makeCluster(detectCores())
invisible(clusterEvalQ(jobcluster, library(tm)))
invisible(clusterEvalQ(jobcluster, library(stringi)))
invisible(clusterEvalQ(jobcluster, library(wordcloud)))

# Download data
if (!file.exists("assets/raw_data.zip")){
  download.file(url = "https://d396qusza40orc.cloudfront.net/dsscapstone/dataset/Coursera-SwiftKey.zip", 
  destfile = "assets/raw_data.zip", quiet = FALSE, method="auto")
}

# Unzip the data
if (!file.exists("assets/rawdata")){
  unzip(zipfile = "assets/raw_data.zip", exdir = "assets", overwrite = TRUE)
}
res = file.rename("assets/final","assets/rawdata")


# Read the datasets:

LANGUAGE = 'en_US' # ('de_DE','en_US','fi_FI','ru_RU')
SOURCES = c('blogs','news','twitter')

rdata = list()
for (src in SOURCES){
  path = file.path("assets/rawdata", LANGUAGE, paste(LANGUAGE,".",src,".txt",sep = "") )
  rdata[[src]] = readLines(path, encoding = 'UTF-8', skipNul = TRUE)
}

# Preprocessing 

## Resampling

# There are more than 3 millions lines in the English dataset. To increase the code performance, the files are sampled into smaller chunks.

set.seed( 1234 ); df.blogs  <- sample(rdata$blogs,   0.2 * length(rdata$blogs)) 
set.seed( 1234 ); df.tweets <- sample(rdata$twitter, 0.2 * length(rdata$twitter))
set.seed( 1234 ); df.news   <- sample(rdata$news,    0.2 * length(rdata$news))

## Corpus creation

corpus = VCorpus(VectorSource(c(df.blogs,df.tweets,df.news)))
rm(df.blogs);rm(df.news);rm(df.tweets)

## Data cleanup
# Helper functions
removeURL <- function(x) gsub("http:[[:alnum:]]*", "", x)
removeHashTags <- function(x) gsub("#\\S+", "", x)
removeTwitterHandles <- function(x) gsub("@\\S+", "", x)
removeSpecialChars <- function(x) gsub("[^a-zA-Z0-9 ]","",x)

# Remove handles and hashtags
corpus["en_US.twitter.txt"] = tm_map(corpus["en_US.twitter.txt"], removeHashTags)
corpus["en_US.twitter.txt"] = tm_map(corpus["en_US.twitter.txt"], removeTwitterHandles)

# Remove URLs
text.corpus = tm_map(corpus, removeURL)

# remove special characters
corpus =  tm_map(corpus, removeSpecialChars)

# convert to lowercase
corpus = tm_map(corpus, tolower)

# remove punctuation
corpus = tm_map(corpus, removePunctuation)

# remove numbers
corpus = tm_map(corpus, removeNumbers)

# strip whitespace
corpus = tm_map(corpus, stripWhitespace)

corpus = tm_map(corpus, PlainTextDocument)


## Tokenizer 
ngrams = list();
for(i in 1:6) {
  print(paste0("Extracting", " ", i, "-grams from corpus"))
  tokens = function(x) unlist(lapply(ngrams(words(x), i), paste, collapse = " "), use.names = FALSE)
  TDM = TermDocumentMatrix(corpus, control = list(tokenize = tokens))
  TDM = sort(slam::row_sums(TDM, na.rm = T), decreasing=TRUE)
  TDM = data.table(token = names(TDM), count = unname(TDM)) 
  TDM[,  paste0("w", seq(i)) := tstrsplit(token, " ", fixed=TRUE)]
  TDM$token = NULL
  TDM[,freq:=count/sum(count)]
  TDM = subset(TDM, count>1)
  ngrams[[i]]=TDM
}

# Save a single object to a file
saveRDS(ngrams, "assets/ngrams.rds")

