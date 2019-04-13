
library(staRdom)
library(tidyverse)

## load data

eems <- eem_read_csv(path = "../Data/corrected csvs 190311",
                     is_blank_corrected = TRUE,
                     is_scatter_corrected = TRUE,
                     is_ife_corrected = TRUE,
                     is_raman_normalized = TRUE,
                     manufacturer = "Horiba")

## outlier removal

eems2 <- eem_exclude(eems, list('em' = 541.27,
                                'ex' = c(246, 249, 252), 
                                'sample' = c('1607_SFPR_EMR_1', 
                                             '1605_SFMG_EML_1', 
                                             '1608_SFMG_EML_1',
                                             '1605_REDC_EML_1', 
                                             '1605_SFMD_EML_1', 
                                             '1605_SFCD_EML_1')))

## initial split-half analysis

comps <- c(3:12)

sp_hf <- list()

for (i in 1:length(comps)) {
  
  set.seed(42)
  sp_hf[[i]] <- splithalf(eem_list = eems2, comps = comps[i], rand = TRUE, normalise = TRUE)
  
}

## save evidence supporting 4-component model

save(sp_hf, file = 'split-half.rdata')

## comp intensive model

pf_0 <- eem_parafac(eems2, comps = 4, maxit = 10000, normalise = TRUE, 
                    nstart = 20, ctol = 10^-5, verbose = TRUE)

eempf_compare(pf_0)

save(pf_0, file = 'comp intensive parafac 4-1.RData')

## identify outliers

lev_0 <- eempf_leverage(pf_0[[1]])

eempf_leverage_plot(lev_0)

#I tried re-running the model with the 3 sample outliers removed, but improvement #was negligible. 

# export results to openfluor

pf_rescale <- eempf_rescaleBC(pf_0[[1]])

eempf_openfluor(pf_rescale, file = '4-1-pf.txt')
