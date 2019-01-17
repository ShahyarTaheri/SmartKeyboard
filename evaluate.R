# Read file
readRDS("assets/ngrams.rds")

predict_word = function (sentence, n=10){
  # follow a similar preparation path as the large corpus
  sentence <- removeNumbers(sentence)
  sentence <- removePunctuation(sentence)
  sentence <- tolower(sentence)
  
  # split into words
  words <- unlist(strsplit(sentence, split = " " ))
  
  # only focus on last 5 words
  words <- tail(words, 5)
  
  word1 <- words[1];word2 <- words[2];word3 <- words[3];word4 <- words[4];word5 <- words[5];
  datasub <- data.table()
  
  if (nrow(datasub)==0 & !is.na(word5)) {
    if(nrow(datasub) == 0) datasub <- subset(ngrams[[6]], w1==word1 & w2==word2 & w3==word3 & w4==word4 & w5==word5)
    if(nrow(datasub) == 0) datasub <- subset(ngrams[[5]], w1==word2 & w2==word3 & w3==word4 & w4==word5)
    if(nrow(datasub) == 0) datasub <- subset(ngrams[[4]], w1==word3 & w2==word4 & w3==word5)
    if(nrow(datasub) == 0) datasub <- subset(ngrams[[3]], w1==word4 & w2==word5)
    if(nrow(datasub) == 0) datasub <- subset(ngrams[[2]], w1==word5)
  }
  
  if (nrow(datasub)==0 & !is.na(word4)) {
    if(nrow(datasub) == 0) datasub <- subset(ngrams[[5]], w1==word1 & w2==word2 & w3==word3 & w4==word4)
    if(nrow(datasub) == 0) datasub <- subset(ngrams[[4]], w1==word2 & w2==word3 & w3==word4)
    if(nrow(datasub) == 0) datasub <- subset(ngrams[[3]], w1==word3 & w2==word4)
    if(nrow(datasub) == 0) datasub <- subset(ngrams[[2]], w1==word4)
  }
  
  if (nrow(datasub)==0 & !is.na(word3)) {
    if(nrow(datasub) == 0) datasub <- subset(ngrams[[4]], w1==word1 & w2==word2 & w3==word3)
    if(nrow(datasub) == 0) datasub <- subset(ngrams[[3]], w1==word2 & w2==word3)
    if(nrow(datasub) == 0) datasub <- subset(ngrams[[2]], w1==word3)
  }
  
  if (nrow(datasub)==0 & !is.na(word2)) {
    if(nrow(datasub) == 0) datasub <- subset(ngrams[[3]], w1==word1 & w2==word2)
    if(nrow(datasub) == 0) datasub <- subset(ngrams[[2]], w1==word2)
  }
  
  if (nrow(datasub)==0 & !is.na(word1)) {
    if(nrow(datasub) == 0) datasub <- subset(ngrams[[2]], w1==word1)
    if(nrow(datasub) == 0) datasub <- head(ngrams[[1]])
  }
  
  if(nrow(datasub) > 0){
    datasub$freq <- datasub$count / sum(datasub$count)
    as.data.frame(head(datasub[order(-freq)], min(n, nrow(datasub))))
  }  
  
}

