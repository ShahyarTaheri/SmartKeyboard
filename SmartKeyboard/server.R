library(data.table)
library(memoise)

function(input, output,session) {
  # Read file
  tritest = fread("./ngrams.csv")
  words = unique(tritest[,word3])
  
  wordcloud_rep = repeatable(wordcloud2)
  
  create_model<-function(bigram){
    
    setkey(tritest,word1,word2,word3)
    matchTrigram=tritest[.(bigram[1],bigram[2],words)]
    matchTrigram$ml=matchTrigram[,N]/tritest[.(bigram[1],bigram[2]),.(count=sum(N))]$count
    #matchTrigram
    setkey(tritest,word2,word3)
    matchBigram=tritest[.(bigram[2],matchTrigram[is.na(N),word3])][,.(N=sum(N)),by=.(word2,word3)]
    matchBigram$ml=(matchBigram[,N]/tritest[.(bigram[2]),.(count=sum(N))]$count)*0.4
    #matchBigram
    setkey(tritest,word3)
    matchUnigram=tritest[.(matchBigram[is.na(N),word3])][,.(N=sum(N)),by=.(word3)]
    matchUnigram$ml=(matchUnigram[,N]/tritest[,.(count=sum(N))]$count)*0.4
    model=rbind(matchTrigram[!(is.na(ml)),.(word3,ml)],matchBigram[!(is.na(ml)),.(word3,ml)],matchUnigram[!(is.na(ml)),.(word3,ml)])
    setkey(model,ml)
    model
  }
  
  create_model_c=memoise(create_model)
  
  get_inputWords<-function(inputText){
    inputText=paste("0 0 ",inputText)
    inputText=gsub("[\\.\\?\\!]+\\s+"," 0 0 ",inputText)
    inputWords=strsplit(inputText,"[[:space:]]+")[[1]]
    inputWords=gsub("\\W+","",inputWords[(length(inputWords)-2):(length(inputWords))],perl=T)
    return(tolower(inputWords))
  }
  firstup<-function(x) {
    substr(x, 1, 1) <- toupper(substr(x, 1, 1))
    x
  }
  
  predict<-reactive({
    inputWords=get_inputWords(input$text)

    if(grepl("[[:space:]]+$",input$text)||length(inputWords)==2){
      predictions = c()
      bigram=inputWords[(length(inputWords)-1):(length(inputWords))]
      model = create_model_c(bigram)
      output$plot <- renderWordcloud2({
        data = data.frame(word=model[(.N-10):.N]$word3, freq = model[(.N-10):.N]$ml)
        wordcloud_rep(data, backgroundColor = "#ECF0F5")
      })
      predictions=model[(.N-2):.N]$word3
      if (sum(grepl("0",bigram))==2){return(firstup(predictions))}
      return(predictions)  
    }
    else{
      predictions=c()
      freq=c()
      bigram=inputWords[(length(inputWords)-2):(length(inputWords)-1)]
      currentWord=inputWords[length(inputWords)]
      model= create_model_c(bigram)
      match=model[grepl(paste("^",currentWord,sep=""),x = model$word3,ignore.case = T),]

      if(length(match)>=1){
        output$plot <- renderWordcloud2({})
          
        max1=which.max(match$ml)
        max1Word=match$word3[max1]
        predictions=c(predictions,max1Word)
        freq = c(freq,match$ml[max1])
        match=match[-max1,]
        if(length(match)>=1){
          max2=which.max(match$ml)
          max2Word=match$word3[max2]
          predictions=c(predictions,max2Word)
          freq = c(freq,match$ml[max2])
          match=match[-max2,]
          if(length(match)>=1){
            max3=which.max(match$ml)
            max3Word=match$word3[max3]
            predictions=c(predictions,max3Word)
            freq = c(freq,match$ml[max3])
          }
        }
      }
      
      output$plot <- renderWordcloud2({
        data = data.frame(word=predictions, freq = freq)
        wordcloud_rep(data, backgroundColor = "#ECF0F5")
      })
      
      if (sum(grepl("0",bigram))==2){return (firstup(predictions))}
      return(predictions)  
    }
    
  })
  
  updateTextField<-function(nthPrediction){
    predictions=predict()
    if (input$text==""){
      updatedText = paste(predictions[nthPrediction]," ",sep="")
    }
    else{
      predictedWord = paste(paste(" ",predictions[nthPrediction],sep="")," ",sep="")
      updatedText = gsub("\\s+\\S+(?!\\s)$|\\s+$",predictedWord,input$text,perl=T)
    }
    updateTextInput(session, "text", value=updatedText)
  }
  
  output$predictionButtons <- renderUI({
    predictions=predict()
    if (length(predictions)==3){
      list(
        actionButton("prediction2", label = predictions[2]),
        actionButton("prediction1", label = predictions[1]),
        actionButton("prediction3", label = predictions[3])
      )
    }
    else if (length(predictions)==2){
      list(
        actionButton("prediction2", label = predictions[2]),
        actionButton("prediction1", label = predictions[1])
      )
    }
    else if (length(predictions)==1){
      list(
        actionButton("prediction1", label = predictions[1])
      )
    }
    
  })
  observeEvent(input$prediction1, {
    updateTextField(1)
  })
  observeEvent(input$prediction2, {
    updateTextField(2)
  })
  observeEvent(input$prediction3, {
    updateTextField(3)
  })  
}