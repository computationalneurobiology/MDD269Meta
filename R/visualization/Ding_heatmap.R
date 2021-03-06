library(cowplot)
library(ggplot2)
library(googledrive)
library(googlesheets4)
library(here)
library(readr)
library(dplyr)
library(tidyr)
#This script creates a heatmap showing the direction of expression of the top 12 genes in the Ding raw results
drawDing <- function() {
  top_genes <- c("MANEA","UBE2M","CKB","ITPR3","SPRY2","SAMD5","TMEM106B","ZC3H7B","LST1","ASXL3","HSPA1A","ZNF184")  
  
  #read in Ding data
  Ding <- read_csv(here("Processed_Data/DingEtAl/CompleteDingTable.csv"))
  Ding %<>% filter(gene_symbol %in% top_genes)
  
  Ding %<>% mutate(expression_direction = sign(effectsize)*log10(P.Value)*-1)
  
  #add in ITPR3 dummy data of 0's
  itpr3_row <- Ding %>% dplyr::select(brain_region) %>% distinct()
  itpr3_row %<>% mutate(gene_symbol = "ITPR3",
                        expression_direction = NA)
  
  Ding_male <- Ding %>% filter(sex == "male") %>% dplyr::select(gene_symbol, brain_region, expression_direction)
  Ding_male %<>% rbind(itpr3_row)
  Ding_female <- Ding %>% filter(sex == "female")%>% dplyr::select(gene_symbol, brain_region, expression_direction)
  Ding_female %<>% rbind(itpr3_row)
  
  #arrange these genes with significant ones together 
  Ding_male %<>% mutate(gene_symbol = factor(gene_symbol, levels=rev(c("HSPA1A","ZC3H7B", "ITPR3", "UBE2M", "CKB", "SAMD5", "SPRY2", "TMEM106B", "LST1","ASXL3", "MANEA","ZNF184"))))
  Ding_female %<>% mutate(gene_symbol = factor(gene_symbol, levels=rev(c("HSPA1A","ZC3H7B", "ITPR3", "UBE2M", "CKB", "SAMD5", "SPRY2", "TMEM106B", "LST1","ASXL3", "MANEA","ZNF184"))))
  
  ding_male_regions <- Ding_male$brain_region
  ding_male_symbol <- Ding_male$gene_symbol
  ding_male_direction <- Ding_male$expression_direction
  
  ding_female_regions <- Ding_female$brain_region
  ding_female_symbol <- Ding_female$gene_symbol
  ding_female_direction <- Ding_female$expression_direction
  
  #source file that has the drawExpressionHeat function 
  source(here("R/visualization/heatmaps.R"))
  #function returns the heatmaps of both sexes combined
  Ding_plots <- drawExpressionHeat(Ding_male, Ding_female, ding_male_regions, ding_male_symbol, ding_female_regions, ding_female_symbol, ding_male_direction, ding_female_direction)
  # add title to the combined plots 
  title <- ggdraw() + draw_label("Ding, et al.", fontface = "bold",size = 20)
  # plot heatmap
  ding_heat <- plot_grid(title, Ding_plots,ncol = 1, rel_heights = c(0.1, 1))
  ggsave(filename = here('Results/Heatmaps/top_genes_Ding_expression_heatmap.png'),dpi=300, width=12, height=8)
  return(ding_heat)
  
}