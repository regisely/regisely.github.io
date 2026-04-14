library(tidyverse)

econ_miss <- economics$unemploy
econ_miss[sample(1:length(econ_miss), 5)] <- 10000

ts.plot(econ_miss)

library(DescTools)
ts.plot(Winsorize(econ_miss))

econ_miss_d <- diff(econ_miss)
par(mfrow = c(2,1))
ts.plot(econ_miss)
ts.plot(cumsum(Winsorize(diff(econ_miss))))

tibble(airquality) %>%
  filter(is.na(Ozone))

ts.plot(airquality$Ozone)

tibble(airquality) %>%
  drop_na(Ozone)

library(Hmisc)
ozone <- airquality$Ozone
ts.plot(impute(ozone, mean))

library(DMwR)
ts.plot(knnImputation(airquality)$Ozone)
