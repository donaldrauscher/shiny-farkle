library(shiny)
library(dplyr)

# import data
stats1 <- read.csv("data/stats1.csv", header = TRUE, stringsAsFactors = FALSE)
stats2 <- read.csv("data/stats2.csv", header = TRUE, stringsAsFactors = FALSE)

# play
play <- function(bank, remaining, depth = 1, max_depth = 3, verbose = FALSE){
  if (verbose){
    print(sprintf("bank: %s; remaining: %s; depth: %s", bank, remaining, depth))
  }
  info <- stats1 %>% filter(n_roll == remaining) %>% as.list(.)
  if (depth < max_depth){
    outcomes <- stats2[stats2$n_roll == remaining,]
    outcomes$remaining2 <- outcomes$remaining; outcomes$remaining2[outcomes$remaining2 == 0] <- 6
    addl_plays <- outcomes %>% filter(!no_score) %>% rowwise() %>% do(as.data.frame(play(.$avg_score + bank, .$remaining2, depth + 1, max_depth, verbose)))
    outcomes$roll <- FALSE; outcomes$bank <- 0; outcomes$zero_score <- 1
    outcomes[!outcomes$no_score, c("roll", "bank", "zero_score")] <- addl_plays[,c("roll", "bank", "zero_score")]
    avg_play_bank <- sum(outcomes$bank * outcomes$prob)
    avg_play_zero_score <- sum(outcomes$zero_score * outcomes$prob)
    if (verbose){
      print(outcomes)
    }
  } else {
    avg_play_bank <- (bank + info$avg_score) * (1 - info$zero_score)
    avg_play_zero_score <- info$zero_score
  }
  return(list(
    "roll" = avg_play_bank > bank,
    "bank" = max(avg_play_bank, bank),
    "zero_score" = ifelse(avg_play_bank > bank, avg_play_zero_score, 0),
    "avg_play_bank" = avg_play_bank,
    "avg_play_zero_score" = avg_play_zero_score
  ))
}

# set up app
ui <- fluidPage(
  tags$div(style="width:400px; display:block; margin-left:auto; margin-right:auto; text-align:center;",
    titlePanel("Farkle Optimizer"),
    img(src='farkle_logo.jpg', align = "center"),
    hr(),
    inputPanel(
      sliderInput(inputId = "remaining", label = "Number of dice left to roll:", value = 6, min = 1, max = 6),
      numericInput(inputId = "bank", label = "Points earned so far:", value = 0, min = 0),
      numericInput(inputId = "max_depth", label = "Roll look-forward:", value = 3, min = 1, max = 10)
    ),
    htmlOutput("text")
  )
)

server <- function(input, output) {
  output$text <- renderUI({
    result <- play(input$bank, input$remaining, 1, input$max_depth)
    roll <- ifelse(result$roll, "Keep Rolling!", "Stop!")
    bank <- sprintf("Expected points: %0.1f", round(result$avg_play_bank))
    zero_score <- sprintf("Probability of scoring zero points: %.1f%%", result$avg_play_zero_score*100)
    HTML(paste0(h3(roll), h5(bank), h5(zero_score)))
  })

}

shinyApp(ui = ui, server = server)
