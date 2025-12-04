import os
import json
from azure.core.credentials import AzureKeyCredential
from azure.search.documents import SearchClient
from azure.search.documents.indexes import SearchIndexClient
from azure.cosmos import CosmosClient
from azure.identity import DefaultAzureCredential
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Cosmos DB configuration
cosmos_endpoint = os.getenv("COSMOS_ENDPOINT")
cosmos_key = os.getenv("COSMOS_KEY")
database_name = "zava"
container_name = "product_catalog"

# AI Search configuration
search_endpoint = os.getenv("SEARCH_ENDPOINT")
search_admin_key = os.getenv("SEARCH_ADMIN_KEY")
index_name = "zava-product-catalog"

def read_cosmos_data():
    """Read all documents from Cosmos DB"""
    print(f"Connecting to Cosmos DB: {cosmos_endpoint}")
    
    # Try AAD auth first (required when disableLocalAuth=true)
    try:
        credential = DefaultAzureCredential()
        client = CosmosClient(cosmos_endpoint, credential=credential)
        print("Using Azure AD authentication")
    except Exception as e:
        print(f"AAD auth failed, trying with key: {e}")
        client = CosmosClient(cosmos_endpoint, credential=cosmos_key)
        print("Using key authentication")
    
    database = client.get_database_client(database_name)
    container = database.get_container_client(container_name)
    
    print(f"Querying all items from container: {container_name}")
    query = "SELECT * FROM c"
    items = list(container.query_items(query=query, enable_cross_partition_query=True))
    print(f"Retrieved {len(items)} documents from Cosmos DB")
    return items

def upload_to_search(documents):
    """Upload documents to AI Search index"""
    print(f"Connecting to AI Search: {search_endpoint}")
    credential = AzureKeyCredential(search_admin_key)
    search_client = SearchClient(endpoint=search_endpoint, index_name=index_name, credential=credential)
    
    # Transform documents for AI Search
    search_docs = []
    for doc in documents:
        search_doc = {
            "id": doc["id"],
            "ProductID": doc.get("ProductID", ""),
            "ProductName": doc.get("ProductName", ""),
            "ProductCategory": doc.get("ProductCategory", ""),
            "ProductDescription": doc.get("ProductDescription", ""),
            "Price": doc.get("Price", 0.0),
            "content_for_vector": doc.get("content_for_vector", "")
        }
        search_docs.append(search_doc)
    
    print(f"Uploading {len(search_docs)} documents to AI Search index...")
    result = search_client.upload_documents(documents=search_docs)
    
    successful = sum(1 for r in result if r.succeeded)
    failed = sum(1 for r in result if not r.succeeded)
    
    print(f"Upload complete: {successful} succeeded, {failed} failed")
    
    if failed > 0:
        for r in result:
            if not r.succeeded:
                print(f"Failed to upload document {r.key}: {r.error_message}")
    
    return successful, failed

def main():
    print("=== AI Search Import Tool ===")
    print(f"Source: Cosmos DB {database_name}/{container_name}")
    print(f"Target: AI Search index {index_name}\n")
    
    # Read from Cosmos DB
    cosmos_docs = read_cosmos_data()
    
    if len(cosmos_docs) == 0:
        print("No documents found in Cosmos DB. Exiting.")
        return
    
    # Upload to AI Search (without vectors initially - vectorizer will handle it)
    successful, failed = upload_to_search(cosmos_docs)
    
    print(f"\n=== Summary ===")
    print(f"Total documents: {len(cosmos_docs)}")
    print(f"Successfully uploaded: {successful}")
    print(f"Failed: {failed}")
    
    if successful > 0:
        print(f"\nDocuments uploaded to AI Search. The vectorizer will generate embeddings automatically.")

if __name__ == "__main__":
    main()
