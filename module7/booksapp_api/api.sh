
# Get all Books
curl --location --request GET 'https://localhost:5001/authors' -k | jq

# Add New Book
curl --location --request POST 'https://localhost:5001/authors' -k \
--header 'Content-Type: application/json' \
--data-raw '{
    "name": "Eric",
    "books": [
        {
            "title": "Titelxxx"
        }
    ]
}'

#Delete Book
curl --location --request DELETE 'https://localhost:5001/authors/6' -k 