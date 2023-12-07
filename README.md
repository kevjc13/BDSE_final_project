# Movie Dataset Integration

## Table of Contents
1. Introduction
2. Datasets
3. Scripts
4. Usage
5. Contributing
6. License

## Introduction
This project aims to integrate and clean data from different movie-related datasets to create a comprehensive database. The datasets include information from TMBD, IMDB, and Oscar awards.

## Datasets
1. TMDB Movie Dataset

    Filename: 930K_movies_data_entry.sql
    Description: SQL script for creating a table for TMDB movie dataset downloaded from Kaggle.

    Filename: 930K_movies_data_cleaning.sql
    Description: SQL script for cleaning data in the TMDB movie dataset.

2. IMDB Dataset

    Filename: IMBD_dataset_data_entry.sql
    Description: SQL script for creating tables for the IMDB dataset downloaded from the IMDB website.

    Filename: IMBD_dataset_data_cleaning.sql
    Description: SQL script for cleaning data in the IMDB dataset.

3. Oscar Award Dataset

    Filename: Oscar_data_entry.sql
    Description: SQL script for creating a table for the Oscar award dataset downloaded from DLu's GitHub repository.

4. Final Data Integration

    Filename: final_data_entry.sql
    Description: SQL script for final data entry and cleaning. Integrates useful data from all tables, using imdb_id as a foreign key. 
