# SQL Wii U Failure Analysis 🎮🕹️

### The script file can be found here [(link)](https://github.com/luisintalan/sql-wiiufailure/blob/main/WiiU%20SQL%20Queries.sql)

### For a detailed analysis, visit my [Medium article!](https://medium.com/@luisrdintalan/examining-the-failure-of-the-wii-u-with-data-a9a5aaa12940)

The dataset consists of a list of video games with greater than 100,000 copies sold. The csv file from Kaggle was loaded onto Microsoft SQL Server using the built-in import function.

The various features include:

| **Feature** | **Description** |
|---|---|
| Rank  | Ranking of overall sales |
| Name | Name of game  |
| Platform | Platform released in (i.e. PC, PS4, etc.) |
| Year | Year released in |
| Genre | Game genre |
| Publisher | Game publisher |
| NA_Sales | Sales in North America (in millions) |
| EU_Sales | Sales in Europe (in millions) |
| JP_Sales | Sales in Japan (in millions) |
| Other_Sales | Sales in the rest of the world (in millions) |
| Global_Sales | Total worldwide sales |

This comprehensive data analysis delves into the decline of Nintendo's Wii U, examining key factors that contributed to its struggles in the gaming market. 

The exploration spans 
* market share trends
* regional sales dynamics
* impact of strategic choices on game genres and major franchises.

This [SQL script](https://github.com/luisintalan/sql-wiiufailure/blob/main/WiiU%20SQL%20Queries.sql) performs data cleaning and transformation on a video game sales dataset. It includes tasks such as deleting records, altering column data types, and executing SQL queries to analyze gaming platform statistics.
