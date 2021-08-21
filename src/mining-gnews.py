## Mining News Articles from Google News for "karbon biru" & "blue carbon"
## Syarifah A. Dalimunthe, Intan Adhi P. Putri, Ari P.S. Prasojo
## 2021
## Maintainer: Ari P.S. Prasojo

from GoogleNews import GoogleNews
from newspaper import Article
from newspaper import Config
from datetime import date
import pandas as pd
import nltk

#config will allow us to access the specified url for which we are #not authorized. Sometimes we may get 403 client error while parsing #the link to download the article.
nltk.download('punkt')

user_agent = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/50.0.2661.102 Safari/537.36'
config = Config()
config.browser_user_agent = user_agent

# date & keyword
today = date.today()
start = '06/01/2019'
end = '02/28/2021'
lang = 'id'
#keyword = '"blue carbon"'
keyword = '"karbon biru"'

#search news
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
    dict['crawling_date'] = today
    dict['keyword'] = keyword
    dict['date'] = df['datetime'][ind]
    dict['media'] = df['media'][ind]
    dict['tittle'] = article.title
    dict['summary'] = article.summary
    dict['article_text'] = article.text
    dict['link'] = df['link'][ind]
    list.append(dict)
 

#convert to data frame    
news_df = pd.DataFrame(list)

#convert tanggal
news_df['crawling_date'] = pd.to_datetime(news_df['crawling_date']).dt.date
#news_df['tanggal'] = pd.to_datetime(news_df['tanggal']).dt.date

#write to excel
#today.strftime("%d-%m-%Y")
news_df.to_excel('data/crawling_'+
                 start.replace('/','')+ '_'+
                 end.replace('/','')+
                 '_1.xlsx',index=False
                 )
