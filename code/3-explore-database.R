## ************************************************************************
## Project:
## Depicting Mangrove's Potential as Blue Carbon Champion in Indonesia
## 
## Syarifah Aini Dalimunthe/ Research Center for Population, BRIN
## Intan Adhi Perdana Putri/ Research Center for Population, BRIN
## Ari Purwanto Sarwo Prasojo/ Research Center for Population, BRIN
## 
## Code for:
## 3-Explore DNA Database
## -After coding news data in DN analyzer
## 
## Code Writer:
## Ari Purwanto Sarwo Prasojo
## 2021
## ************************************************************************

# Library----
library(rDNA)
library(igraph)
library(dplyr)
library(ggplot2)
library(ggnewscale)
library(ggraph)
library(ggrepel)
# library(janitor)
library(statnet)
library(xlsx)
dna_init()

# News data from google news----
newsdta <- read.xlsx("data/14042021_mining_06012019_02282021.xlsx",1)
glimpse(newsdta)

# # DNA concept----
# dna1 <- dna_connection("dna/DNA_Blue Carbon.dna")
# dna_barplot(dna1,of="concept")
# dna_barplot(dna1,of="organization")
# nw1 <- dna_network(dna1,networkType = "onemode")
# dna_plotNetwork(nw1)
# gplot(nw1)


# DNA concept (recode)----
dna2 <- dna_connection("dna/DNA_Blue Carbon recode topic.dna")
doc <- dna_getDocuments(dna2)
stm <- dna_getStatements(dna2,statementType = "DNA Statement")

## Merging document & statement----
dta <- doc %>% rename(documentId=id) %>% select(-c(text,coder)) %>% 
  left_join(stm,by="documentId") %>% filter(!is.na(concept)) %>% 
  mutate(author=case_when(title=="Berkolaborasi Selamatkan Mangrove di Sulawesi" ~ "Mongabay",
                          TRUE ~ author),
         date1=as.Date(format(date, format = "%Y-%m-%d")))
glimpse(dta)

## Get news used, merge with news data----
newsused <- dta %>% pull(title) %>% unique
newsdta <- newsdta %>%
  mutate(used=sapply(judul,FUN=function(x){as.numeric(any(grepl(x,newsused)))}))

## Descriptive----

### Media distribution----
newsdta %>% filter(used==1) %>% 
  ggplot(aes(media)) +
  geom_bar() +
  ylim(c(0,14)) +
  labs(x="",y="Frequency") +
  geom_text(stat='count', aes(label=..count..),hjust=-.5)+
  coord_flip()

### Time series of statement----
dta %>% mutate(month=format(date1,"%Y-%m"),
               month=as.Date(paste0(month,"-01"),"%Y-%m-%d")) %>% 
  ggplot(aes(month))+
  geom_line(stat="count")+
  geom_vline(aes(xintercept = as.Date("2019-06-01"),color=("event1")))+
  geom_vline(aes(xintercept = as.Date("2020-06-01"),color=("event2")))+
  scale_color_manual(name="Events",
                     values=c(event1="red",event2="blue"),
                     labels=c("-World Environment Day (5th of June)\n-Bonn Climate Change Conference\n (17th-27th of June)",
                              "-World Environment Day (5th of June)"))+
  #new_scale_color()+
  labs(x="",y="Number of statement")+
  #lims(y=c(0,27))+
  scale_x_date(date_labels = "%b %Y",date_breaks = "1 month",
               date_minor_breaks = "1 month")+
  #theme_light()+
  theme(axis.text.x = element_text(angle=90),
        legend.position=c(.83, .85),
        legend.background = element_rect(fill=alpha('white', .7)),
        legend.title=element_text(size=8),
        legend.text=element_text(size=7))
ggsave("trend.png")
    

### Counting frequency of concept----
nrow(stm)
stm %>% group_by(concept) %>% count(concept) %>% arrange(desc(n)) %>% View()

att <- dna_getAttributes(dna2,variable="concept")
dna_barplot(dna2,of="concept")
dna_barplot(dna2,of="organization")

# clust2 <- dna_cluster(dna2)
# dna_plotDendro(clust2)


## One mode network----
nw2 <- dna_network(dna2, networkType = "onemode")
grph <- dna_toIgraph(nw2)
V(grph)$name <- c("BAPPENAS",
                  "Blue Forest",
                  "IPB University",
                  "CIFOR",
                  "Environmental Expert",
                  "Former of England Minister...",
                  "ICCTF",
                  "LIPI",
                  "Indonesian Delegation to Blue...",
                  "Local Economic act...",
                  "MOMAF",
                  "Minister of Climate Change...",
                  "Minister of Maritime...",
                  "Ministry of Maritime...",
                  "Ministry of Environment...",
                  "President of Home Care Unilever",
                  "Soedirman Univ...",
                  "Tanjungpura University",
                  "Task Force of Illegal Fish...",
                  "TNC",
                  "WWF Indonesia",
                  "Yayasan Kehati",
                  "IKAL"
                  )

V(grph)$type <- c("Government","NGO/iNGOs",
                  "University/Researcher","University/Researcher",
                  "University/Researcher","Government","NGO/iNGOs",
                  "University/Researcher","Government","NGO/iNGOs",
                  "Government","Government",
                  "Government","Government",
                  "Government","Private",
                  "University/Researcher","University/Researcher",
                  "Government","NGO/iNGOs",
                  "NGO/iNGOs","NGO/iNGOs",
                  "NGO/iNGOs"
                  )

### Centrality----
V(grph)$degree <- igraph::degree(grph)
# V(grph)$closeness <- igraph::closeness(grph)

### Plot----
edge_size_range <- c(0.1, 2)
show_legend <- TRUE
font_size <- 6
label_repel <- 0.5
label_lines <- FALSE

lyt <- create_layout(grph,layout="auto")
g <- ggraph(lyt) +
  geom_edge_link(aes(width=weight), 
                 alpha = 1, color = "gray", show.legend = TRUE)+
  scale_edge_width(name="Weight",range = edge_size_range) +
  geom_node_point(aes(color = type, size=degree),
                  
                  show.legend = show_legend) +
  scale_color_manual(values=c("#0000cc","#990099","#00ff00","#ffcc00"))+
  guides(col=guide_legend("Actors type",override.aes = list(size=3)),
         size=guide_legend("Centrality"))+
  theme_void() +
  theme(legend.title=element_text(size=8),
        legend.text=element_text(size=7))
  
#-node label
yexp <- (max(lyt$y) - min(lyt$y))/3
xexp <- (max(lyt$x) - min(lyt$x))/3
g <- g + scale_y_continuous(expand = c(0, yexp, 0, yexp)) + 
  scale_x_continuous(expand = c(0, xexp, 0, xexp))

g <- g +
  #geom_label_repel(aes_string(x = "x", y = "y",
  geom_text_repel(aes(x = x, y = y, label = name),
                  point.padding = label_repel, 
                  box.padding = label_repel, fontface = "bold", 
                  size = font_size/.pt,
                  min.segment.length = ifelse(label_lines, 0.5, Inf),
                  max.overlaps=20)
g

ggplot2::ggsave("network-onemode1.png",width=7,height=4,units="in")
