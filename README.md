# Movie Dataset Integration

## Introduction
This project aims to integrate and clean data from different movie-related datasets to create a comprehensive database. The datasets include information from TMBD, IMDB, and Oscar awards.

## Datasets
1. TMDB Movie Dataset

    Filename: 930K_movies_data_entry.sql<br>
    Description: SQL script for creating a table for TMDB movie dataset downloaded from Kaggle.

    Filename: 930K_movies_data_cleaning.sql<br>
    Description: SQL script for cleaning data in the TMDB movie dataset. Removed non-english language movies, movies without imdb_id, movies without a release date, movies released before 1910, movies release date is over 2024, movies were cancelled,  duplicated movies and movies not in IMDB offical dataset.

2. IMDB Official Datasets

    Filename: IMBD_dataset_data_entry.sql<br>
    Description: SQL script for creating tables for the IMDB datasets downloaded from the IMDB website.

    Filename: IMBD_dataset_data_cleaning.sql<br>
    Description: SQL script for cleaning data in the IMDB dataset. Removed movies not in TMDB movie dataset.

3. Oscar Award Dataset

    Filename: Oscar_data_entry.sql<br>
    Description: SQL script for creating a table for the Oscar award dataset downloaded from DLu's GitHub repository. Removed movies not in TMDB movie dataset.

4. Final Data Integration

    Filename: final_data_entry.sql<br>
    Description:
    SQL script for final data entry and cleaning. This script enhances the TMDB dataset by integrating valuable information from various sources. The integration involves adding 43 new columns, including details such as director, writer, cast, IMDb rating, Oscar nominations, Oscar winners, top 4 leading cast, etc. This comprehensive feature engineering process aims to enrich the dataset for more in-depth analysis and insights.
