# # setup run for just ONE code
# ndd <- "DEM"
# code <- "QC0_AB1_VIRAL_SKIN_MUCOUS_MEMBRANE"

args <- commandArgs(trailingOnly = TRUE)

ndd  <- args[1]
code <- args[2]
sims <- as.integer(args[3])

# # install packages
# install.packages("broom")
# install.packages("mediation")

### you might need to restart and 'read' in the prepped_df file below...

library(tidyr)
library(dplyr)
library(mediation) # for mediate()
library(broom) # for tables

# script to help with making the output tables
#generated the table from: # Source - https://stackoverflow.com/a
# Posted by hrbrmstr, modified by community. See post 'Timeline' for change history
# Retrieved 2026-01-28, License - CC BY-SA 3.0

extract_mediation_summary <- function (x) { 
  
  clp <- 100 * x$conf.level
  isLinear.y <- ((class(x$model.y)[1] %in% c("lm", "rq")) || 
                   (inherits(x$model.y, "glm") && x$model.y$family$family == 
                      "gaussian" && x$model.y$family$link == "identity") || 
                   (inherits(x$model.y, "survreg") && x$model.y$dist == 
                      "gaussian"))
  
  printone <- !x$INT && isLinear.y
  
  if (printone) {
    
    smat <- c(x$d1, x$d1.ci, x$d1.p)
    smat <- rbind(smat, c(x$z0, x$z0.ci, x$z0.p))
    smat <- rbind(smat, c(x$tau.coef, x$tau.ci, x$tau.p))
    smat <- rbind(smat, c(x$n0, x$n0.ci, x$n0.p))
    
    rownames(smat) <- c("ACME", "ADE", "Total Effect", "Prop. Mediated")
    
  } else {
    smat <- c(x$d0, x$d0.ci, x$d0.p)
    smat <- rbind(smat, c(x$d1, x$d1.ci, x$d1.p))
    smat <- rbind(smat, c(x$z0, x$z0.ci, x$z0.p))
    smat <- rbind(smat, c(x$z1, x$z1.ci, x$z1.p))
    smat <- rbind(smat, c(x$tau.coef, x$tau.ci, x$tau.p))
    smat <- rbind(smat, c(x$n0, x$n0.ci, x$n0.p))
    smat <- rbind(smat, c(x$n1, x$n1.ci, x$n1.p))
    smat <- rbind(smat, c(x$d.avg, x$d.avg.ci, x$d.avg.p))
    smat <- rbind(smat, c(x$z.avg, x$z.avg.ci, x$z.avg.p))
    smat <- rbind(smat, c(x$n.avg, x$n.avg.ci, x$n.avg.p))
    
    rownames(smat) <- c("ACME (control)", "ACME (treated)", 
                        "ADE (control)", "ADE (treated)", "Total Effect", 
                        "Prop. Mediated (control)", "Prop. Mediated (treated)", 
                        "ACME (average)", "ADE (average)", "Prop. Mediated (average)")
    
  }
  
  colnames(smat) <- c("Estimate", paste(clp, "% CI Lower", sep = ""), 
                      paste(clp, "% CI Upper", sep = ""), "p-value")
  smat
  
}

file_path <- file.path(
  getwd(),
  "data/PREPPED_FOR_MEDIATION",
  paste0(ndd, "_", code, "_prepped_df_for_mediation.csv")
)

prepped_df_for_mediation <- read.csv(file_path)

head(prepped_df_for_mediation)

unique(prepped_df_for_mediation$APOE)

# modify to account for the 'NA'
prepped_df_for_mediation$APOE[is.na(prepped_df_for_mediation$APOE)] <- 0

unique(prepped_df_for_mediation$APOE)

# # setup run for just ONE code
# code <- c('QC0_AB1_ANOGENITAL_HERPES_SIMPLEX')
df_subset <- prepped_df_for_mediation

head(df_subset,5)

set.seed(42)

mediator_formula <- reformulate(c('SEX', 'age_at_tenure', 'APOE'),
                                response = code)
model_mediator <- glm(mediator_formula, 
                      data = df_subset, 
                      family = binomial(link = 'logit'))

model_mediator

model_mediator.tidy <- tidy(model_mediator)

model_mediator.tidy <- model_mediator.tidy %>% mutate(SIG = p.value <0.05,
                                                      OR = exp(estimate),
                                                      OR_LOW = exp(estimate - 1.96 * std.error),
                                                      OR_HIGH = exp(estimate + 1.96 * std.error),
                                                      PERCENT_CHANGE = (OR - 1) * 100)

model_mediator.tidy

write.csv(model_mediator.tidy, file = paste0('OUTPUT_INTERMEDIARY_FILES/subset_df_', code, '_mediator_model_',ndd,'.csv'),row.names = FALSE)

# # just make sure it's there...
# files <- system("ls -lh | grep subset_df", intern = TRUE)
# files

outcome_formula <- reformulate(c(code, 'SEX', 'age_at_tenure', 'APOE'),
                             response = 'NDD_BINARY')
model_outcome <- glm(outcome_formula,
                     data = df_subset,
                     family = binomial(link = 'logit'))

set.seed(42)

model_outcome.tidy <- tidy(model_outcome)
model_outcome.tidy <- model_outcome.tidy %>% mutate(SIG = p.value <0.05,
                                                    OR = exp(estimate),
                                                    OR_LOW = exp(estimate - 1.96 * std.error),
                                                    OR_HIGH = exp(estimate + 1.96 * std.error),
                                                    PERCENT_CHANGE = (OR - 1) * 100)
model_outcome.tidy

write.csv(model_outcome.tidy, file = paste0('OUTPUT_INTERMEDIARY_FILES/subset_df_',code,'_outcome_model_',ndd,'.csv'),row.names = FALSE)

# just make sure it's there...
files <- system("ls -lh | grep subset_df", intern = TRUE)
files

print(Sys.time())

set.seed(42)

mediation_result <- mediate(model_mediator, model_outcome, 
                            treat = 'SEX', mediator = code,
                            boot = TRUE, sims = sims)

final_df <- extract_mediation_summary(mediation_result)
final_df <- as.data.frame(final_df)
final_df$Percent <- final_df$Estimate*100

write.csv(final_df, file = paste0('OUTPUT_FINAL_MEDIATION_FILES/subset_df_', code, '_full_mediation_model_',ndd,'.csv'), row.names = TRUE)
print('DONE')

print(Sys.time())
