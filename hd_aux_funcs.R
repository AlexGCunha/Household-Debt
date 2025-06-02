########################################
#Main model for event study regressions
########################################
m_model = function(data, high_debt = c(0,1,NA),
                   skill_level = c(1,2,3,NA),
                   recession = c(0,1, NA),
                   controls = 0, dep_var = "mean_earnings",
                   reference_period = 0, family = "gaussian"){
  data_use = data %>% 
    filter(high_debt_b %in% high_debt,
           skill_b %in% skill_level,
           recession_b1 %in% recession)
  
  if(controls == 0){
    formula = paste0(dep_var, "~i(year_relative_baseline, ref= ",reference_period,
                     "):treated +",
                     "treated | year_relative_baseline")
    formula_use = as.formula(formula)
    
    model = feglm(formula_use,
                  cluster = c("cnpj_cei_b"),
                  data = data_use,
                  family = family)
    
  } else{
    formula = paste0(dep_var, '~ i(year_relative_baseline, ref = ', reference_period,
                     "):treated", 
                     "| year_relative_baseline + cpf + year + munic_b")
    formula_use = as.formula(formula)
    model = feglm(formula_use,
                  cluster = c("cnpj_cei_b"),
                  data = data_use,
                  family = family)
  }
  
  return(model)
    
  
}

########################################
#Model for event study plots
########################################
multi_line_graph = function(models, legends,
                            reference_period = 0, graph_title = 'default', 
                            exponentiate = 0){
  all_models = tibble()
  count = 0
  for(model in models){
    count = count + 1
    aux = tidy(model, conf.int = TRUE) %>% 
      slice((nrow(tidy(model))-periods+2):nrow(tidy(model))) %>% 
      select(term, estimate, conf.low, conf.high) %>% 
      rbind(tibble(term = as.character(reference_period),
                    estimate = 0, conf.low = 0, conf.high = 0)) %>% 
      mutate(period = c(seq(-years_prior, reference_period-1,1),
                        seq(reference_period + 1, years_after, 1),
                        reference_period)) %>% 
      arrange(period) %>% 
      mutate(cat = legends[count])
    
    all_models = rbind(all_models, aux)
  }
  
  #exponentiate when poisson regression
  if(exponentiate== 1){
    all_models = all_models %>% 
      mutate(across(c("estimate", "conf.low", "conf.high"), ~exp(.)-1))
  }
  
  plot = all_models %>% 
    ggplot(aes(x = period, y = estimate, linetype = cat))+
    geom_point()+
    geom_line()+
    geom_errorbar(aes(ymin = conf.low, ymax = conf.high),
                  alpha = 0.5, width = 0.25)+
    geom_hline(yintercept = 0)+theme_minimal()+
    labs(y = '', title = graph_title, x = 'Years Relative to Baseline')
    theme(text = element_text(size = 12),
          panel.grid.major.x = element_blank(),
          panel.grid.minor.x = element_blank(),
          panel.grid.minor.y = element_blank())
  
  if(min(legends != c('')) == 1){
    plot = plot + 
      theme(legend.title = element_blank(),
            legend.position = c(0.15, 0.15))
  } else{
    plot = plot + theme(legend.position = 'none')
  }
  
  return(plot)
}


########################################
#Model for average outcomes after layoffs
########################################
avg_model = function(data, high_debt = c(0,1,NA),
                   skill_level = c(1,2,3,NA),
                   recession = c(0,1, NA),
                   controls = 0, dep_var = "mean_earnings",
                   reference_period = 0, family = "gaussian"){
  data_use = data %>% 
    filter(high_debt_b %in% high_debt,
           skill_b %in% skill_level,
           recession_b1 %in% recession) %>% 
    mutate(pos = ifelse(year_relative_baseline > 0, 1, 0))
  
  if(controls == 0){
    formula = paste0(dep_var, "~treated + pos + treated:pos")
    formula_use = as.formula(formula)
    
    model = feglm(formula_use,
                  cluster = c("cnpj_cei_b"),
                  data = data_use,
                  family = family)
    
  } else{
    formula = paste0(dep_var, 
                     "~treated:pos | pis + ano + munic_b + year_relativo_baseline")
    formula_use = as.formula(formula)
    
    model = feglm(formula_use,
                  cluster = c("cnpj_cei_b"),
                  data = data_use,
                  family = family)
  }
  
  #Exponentiate coefficients if family == poisson
  if(family == 'poisson'){
    model$coeftable[1:nrow(model$coeftable), 1:2] = exp(model$coeftable[1:nrow(model$coeftable), 1:2]) - 1
  }
  
  return(model)
  
}

########################################
#Triple Difference avg results
########################################
triple_diff = function(data, 
                       skill_level = c(1,2,3,NA),
                       recession = c(0,1, NA),
                       dep_var = "mean_earnings",
                       family = "gaussian",
                       td_on = "high_debt_b"){
  data_use = data %>% 
    filter(skill_b %in% skill_level,
           recession_b1 %in% recession) %>% 
    mutate(pos = ifelse(year_relative_baseline > 0, 1, 0))
  
  formula = paste0(dep_var, "~treated + pos + treated:pos")
  formula_use = as.formula(formula)
  
  model = feglm(formula_use,
                cluster = c("cnpj_cei_b"),
                data = data_use,
                family = family)
  
  formula = paste0(dep_var, 
                   "~treated:pos +
                     treated:",td_on,"+
                     pos:",td_on, "+
                     treated:pos:",td_on,"|
                     cpf + year + munic_b + year_relative_baseline")
  formula_use = as.formula(formula)
  
  model = feglm(formula_use,
                cluster = c("cnpj_cei_b"),
                data = data_use,
                family = family)
  
  #Exponentiate coefficients if family == poisson
  if(family == 'poisson'){
    model$coeftable[1:nrow(model$coeftable), 1:2] = exp(model$coeftable[1:nrow(model$coeftable), 1:2]) - 1
  }
  
  return(model)
  
}



