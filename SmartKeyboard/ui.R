shinyUI(dashboardPage (
  skin = "blue",
  dashboardHeader(title = 'Smart Keyboard'),
  dashboardSidebar(
    sidebarUserPanel('Author', subtitle = "Shahyar Taheri",
                     image = 'https://avatars0.githubusercontent.com/u/21279530?s=400&v=4'),
    sidebarMenu(
      menuItem('About', tabName = 'home', icon = icon('home')),
      menuItem('Keyboard',tabName = 'kb',icon = icon('keyboard'))
    )
  ),
  dashboardBody(tabItems(
    tabItem(
      tabName = 'home',
      box(title = 'About',status = 'info',solidHeader = F, width = 12,
          p("This is a smart keyboard application that can predict users next word while typing.")),
      box(title = 'How does it work?',status = 'info',solidHeader = F, width = 12,
          p("The model uses N-grams method to assign probabilities to sequence of words and predict the next word in a sentence. "),
          p("To keep the language model from assigning zero probability to unseen combinations, the Stupid backoff smoothing (discounting) is used. 
            This method gives up the idea of trying to make the language model a true probability distribution. There is no discounting of the higher-order probabilities. 
            If a higher-order N-gram has a zero count, we simply backoff to a lower order N-gram, weighed by a fixed (context-independent) weight. 
            This algorithm does not produce a probability distribution")),
      box(title = 'More Information',status = 'info',solidHeader = F, width = 12,
          p("To learn more about natural language processing methods used in this app refer to the following links: "),
          tags$ul(
            tags$li(tags$a(href="https://rpubs.com/staheri/NLP-WordPrediction", "NLP Exploratory Analysis")),
            tags$li(tags$a(href="https://en.wikipedia.org/wiki/N-gram", "N-gram Model")),
            tags$li(tags$a(href="http://www.aclweb.org/anthology/D07-1090", "Stupid Backoff Model")),
            tags$li(tags$a(href="https://en.wikipedia.org/wiki/Kneser%E2%80%93Ney_smoothing", "Knser-Ney Smoothing"))
            )
      )
          
      ),
    tabItem(
      tabName = 'kb',
      fluidRow(
      #shinythemes::themeSelector(),
      tags$head(
        tags$link(rel = "stylesheet", href = "//fonts.googleapis.com/css?family=Raleway|Cormorant"),
        tags$script(src="script_c.js"),
        tags$link(rel = "stylesheet", href="style.css")
      ),
      tags$br(),
      tags$br(),
      tags$div(class="boxx",
               tags$div(class="content",
                        tags$div(textAreaInput("text",width="170%",label="", value = "", placeholder = "Type here ..."),
                        tags$div(id="button-container",
                                 uiOutput("predictionButtons"))
                        )
               )
      )),
      fluidRow(
      withSpinner(wordcloud2Output("plot", width = "auto"))
      )
    )
    ))
))
