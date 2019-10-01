library(staRdom)
library(tidyverse)

## this script involves some random subsampling so:
set.seed(42)
# this allows me to control when the model recalculates using a new rand. vector

## load data

eems <- eem_read_csv(path = "../Data/corrected csvs 190311",
                     is_blank_corrected = TRUE,
                     is_scatter_corrected = TRUE,
                     is_ife_corrected = TRUE,
                     is_raman_normalized = TRUE,
                     manufacturer = "Horiba")

## preliminary PARAFAC run

pf1 <- eem_parafac(eems, comps = 1:10, normalise = TRUE, 
                    verbose = TRUE, cores = 1)

#1-3 violate Stokes shift so 4 is the bottom limit

#8-10 didn't seem to converge

pf2 <- eem_parafac(eems, comps = 8:10, normalise = TRUE,
                   maxit = 5000, ctol = 1e-5, cores = 1,
                   verbose = TRUE)

# 9 and 10 still didn't converge so 8 is upper limit

pf1 <- pf1[4:8]

pf1[5] <- pf2[1]

eempf_compare(pf1)

## core consistency

cc <- unlist(lapply(pf1, function(x) eempf_corcondia(x, eem_interp(eems, type = 0))))

cc

## outlier removal & split-half analysis

### 4C

lev4 <- eempf_leverage(pf1[[1]])
eempf_leverage_plot(lev4)
eems4 <- eem_exclude(eems, list('ex' = c(246,249),
                                'sample' = c('1607_SFPR_EMR_1')))
sh4 <- splithalf(eem_list = eems4, comps = 4, rand = TRUE, normalise = TRUE)
splithalf_plot(sh4)

### 5C

lev5 <- eempf_leverage(pf1[[2]])
eempf_leverage_plot(lev5)
eems5 <- eem_exclude(eems, list('ex' = c(246,249, 252),
                                'sample' = c('1607_SFPR_EMR_1', 
                                             '1605_SFMG_EML_1', 
                                             '1608_SFMG_EML_1',
                                             '1605_REDC_EML_1', 
                                             '1605_SFMD_EML_1', 
                                             '1605_SFCD_EML_1')))
sh5 <- splithalf(eem_list = eems5, comps = 5, rand = TRUE, normalise = TRUE)

sh5on4 <- splithalf(eem_list = eems5, comps = 4, rand = TRUE, normalise = TRUE)