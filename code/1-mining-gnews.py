## ************************************************************************
## Project:
## Depicting Mangrove's Potential as Blue Carbon Champion in Indonesia
## 
## Syarifah Aini Dalimunthe/ Research Center for Population, BRIN
## Intan Adhi Perdana Putri/ Research Center for Population, BRIN
## Ari Purwanto Sarwo Prasojo/ Research Center for Population, BRIN
## 
## Code for:
## 1-Mining News from Google News Agregator
## 
## Code Writer:
## Ari Purwanto Sarwo Prasojo
## 2021
##
## Adapted from: Dhingra (2020)
## link: https://medium.com/analytics-vidhya/googlenews-api-live-news-from-google-news-using-python-b50272f0a8f0
## ************************************************************************



# Library----
from GoogleNews import GoogleNews
from newspaper import Article
from newspaper import Config
from datetime import date
import pandas as pd
import nltk

# Config----
#-config will allow us to access the specified url for which we are #not authorized. Sometimes we may get 403 client error while parsing #the link to download the article.
nltk.download('punkt')

user_agent = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/50.0.2661.102 Safari/537.36'
config = Config()
config.browser_user_agent = user_agent


# Date & keyword----
#-mining at 14/04/2021
today = date.today()
start = '06/01/2019'
end = '02/28/2021'
lang = 'id'
#keyword = '"blue carbon"'
keyword = '"karbon biru"'


# Search & mining news----
googlenews = GoogleNews(lang=lang,start=start,end=end)
#googlenews = GoogleNews(lang=lang)
googlenews.search(keyword)

#result = googlenews.result()
#df = pd.DataFrame(result)
#print(df.head())

for i in range(1,20):
    googlenews.getpage(i)
    result = googlenews.result()
    df = pd.DataFrame(result)

list=[]

for ind in df.index:
    dict={}
    article = Article(df['link'][ind],language=lang, config=config)
    article.download()
    article.parse()
    article.nlp()
    dict['mining_date'] = today
    dict['keyword'] = keyword
    dict['date'] = df['datetime'][ind]
    dict['media'] = df['media'][ind]
    dict['tittle'] = article.title
    dict['summary'] = article.summary
    dict['article_text'] = article.text
    dict['link'] = df['link'][ind]
    list.append(dict)

 
# Convert----
#-convert to data frame    
news_df = pd.DataFrame(list)

#-convert date
news_df['mining_date'] = pd.to_datetime(news_df['mining_date']).dt.date
#news_df['date'] = pd.to_datetime(news_df['date']).dt.date


# Write to excel----
#today.strftime("%d-%m-%Y")
# news_df.to_excel('data/mining_'+
#                  start.replace('/','')+ '_'+
#                  end.replace('/','')+
#                  '.xlsx',index=False
#                  )
news_df.to_excel('data/mining_'+
                 start.replace('/','')+ '_'+
                 end.replace('/','')+
                 '_1.xlsx',index=False
                 )
