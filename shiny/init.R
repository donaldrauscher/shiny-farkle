library(dplyr)

# create roll universes
rolls <- do.call(rbind, lapply(1:6, function(i){
  temp <- do.call(expand.grid, lapply(1:i, function(x) 1:6))
  temp <- do.call(cbind, lapply(1:6, function(x) apply(temp, 1, function(y) sum(ifelse(y == x, 1, 0)))))
  temp <- as.data.frame(temp) %>% group_by(V1,V2,V3,V4,V5,V6) %>% summarise(prob = n())
  temp$prob <- temp$prob / sum(temp$prob)
  temp$n_roll <- i
  return(temp)
}))

# calculate score and dice remaining for each roll
score <- function(n1,n2,n3,n4,n5,n6){
  counts <- c(n1,n2,n3,n4,n5,n6)
  n_pairs <- sum(ifelse(counts == 2, 1, 0))
  n_trips <- sum(ifelse(counts == 3, 1, 0))
  remainder <- counts
  zeros <- rep(0, sum(counts))
  points <- 0
  if (max(counts) == 6){
    remainder <- zeros; points <- 3000
  } else if (n_trips == 2){
    remainder <- zeros; points <- 2500
  } else if (max(counts) == 5){
    remainder[remainder == 5] <- 0; points <- 2000
  } else if (all(counts == rep(1,6))){
    remainder <- zeros; points <- 1500
  } else if ((n_pairs == 3) | (n_pairs == 1 & max(counts) == 4)){
    remainder <- zeros; points <- 1500
  } else if (max(counts) == 4){
    remainder[remainder == 4] <- 0; points <- 1000
  } else if (counts[6] == 3){
    remainder[6] <- 0; points <- 600
  } else if (counts[5] == 3){
    remainder[5] <- 0; points <- 500
  } else if (counts[4] == 3){
    remainder[4] <- 0; points <- 400
  } else if (counts[3] == 3){
    remainder[3] <- 0; points <- 300
  } else if (counts[2] == 3){
    remainder[2] <- 0; points <- 200
  } else if (counts[1] == 3){
    remainder[1] <- 0; points <- 300
  } else {
    points <- 0
  }
  points <- points + remainder[1]*100 + remainder[5]*50
  remainder[1] <- 0; remainder[5] <- 0
  return(c(points, sum(remainder)))
}

temp <- mapply(score, rolls$V1, rolls$V2, rolls$V3, rolls$V4, rolls$V5, rolls$V6)
rolls$score <- temp[1,]; rolls$remaining <- temp[2,]

# calculate some stats for our simulation
stats1 <- rolls %>% group_by(n_roll) %>% summarise(
  zero_score = sum(ifelse(score == 0, prob, 0)),
  avg_score = sum(prob * score) / (1 - zero_score)
)

stats2 <- rolls %>%
  group_by(n_roll, remaining) %>%
  summarise(avg_score = sum(prob * score) / sum(prob), prob = sum(prob)) %>%
  mutate(no_score = (n_roll == remaining))

# export
write.csv(stats1, "data/stats1.csv", row.names = FALSE)
write.csv(stats2, "data/stats2.csv", row.names = FALSE)
