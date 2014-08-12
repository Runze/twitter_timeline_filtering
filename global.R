library(twitteR)
library(stringr)
library(plyr)

load('data/my_oauth.RData')
registerTwitterOAuth(my_oauth)

get_tl = function() {
  #retrieve timeline and users
  tl = twListToDF(homeTimeline(n = 400))
  users = twListToDF(lookupUsers(unique(tl[, 'screenName'])))
  
  #process profile image
  users$prof_img = sprintf("<img src='%s'></img>", users$profileImageUrl)
  users = subset(users, select = c(screenName, prof_img))
  
  tl = merge(tl, users, by = 'screenName')
  
  #extract url from tweets
  url = str_extract_all(tl$text, 'http://t.co/[[:alnum:]]+|https://t.co/[[:alnum:]]+')
  tl$text = str_replace_all(tl$text, 'http://t.co/[[:alnum:]]+|https://t.co/[[:alnum:]]+', '')
  url_len = max(unlist(lapply(url, length)))
  
  for (i in 1:url_len) {
    url_temp = unlist(lapply(url, function(x) x[i]))
    url_temp[which(is.na(url_temp))] = ''
    tl[paste0('url', i)] = sprintf("<a href='%s' target='_blank'>%s</a>", url_temp, url_temp)
  }
  
  #clean up text
  text = str_replace_all(tl$text, '[^[:graph:]]', ' ')
  text = str_replace(text, '^ +', '')
  text = str_replace(text, ' +$', '')
  text = str_replace(text, '  +', ' ')
  tl$text = text
  
  #calculate average retweet + favorite count
  tl$rt_fav = tl$retweetCount + tl$favoriteCount
  mean_rt_fav = ddply(tl, .(screenName), summarize, mean_rt_fav = mean(rt_fav))
  tl = merge(tl, mean_rt_fav, by = 'screenName')
  
  #calculate rt/fav-to-average rt/fav ratio
  rt_fav_ratio = tl$rt_fav / tl$mean_rt_fav
  tl$rt_fav_rk = rank(-rt_fav_ratio)
  
  #subset to keep only the top 100
  tl = subset(tl, rt_fav_rk <= 100)
  
  #split date and time
  dt = ldply(str_split(tl$created, ' '))
  names(dt) = c('date', 'time')
  tl = cbind(tl, dt)
  
  #final clean-up
  urls = unlist(str_extract_all(names(tl), 'url.'))
  tl = tl[c('screenName', 'prof_img', 'text', urls, 'date', 'time')] 
  names(tl)[1:3] = c('name', ' ', 'tweet')
  tl = tl[order(tl$date, tl$time, decreasing = T), ]
  return(tl)
}