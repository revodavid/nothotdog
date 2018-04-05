## use the custom vision API to create a function that identifies
## whether an image on the web is a hotdog or not

## You can see the effects of your API calls as you go by browsing to
## https://www.customvision.ai/projects and logging in with your Microsoft Account

## Overview
## https://docs.microsoft.com/en-us/azure/cognitive-services/custom-vision-service/home

## training API reference
## https://southcentralus.dev.cognitive.microsoft.com/docs/services/fde264b7c0e94a529a0ad6d26550a761/operations/59568ae208fa5e09ecb9983a
## prediction API reference:
## https://southcentralus.dev.cognitive.microsoft.com/docs/services/57982f59b5964e36841e22dfbfe78fc1/operations/5a3044f608fa5e06b890f164

library(httr)
library(jsonlite)

## Read in a file of URLs of images of hotdogs, and also a file
## of URLs of images that are somewhat similar to, but not, hotdogs
hotdogs <- scan("hotdogs-good.txt",what=character())
nothotdogs <- scan("nothotdogs-good.txt", what=character())

## NOTE: We created the file hotdogs-good.txt and nothotdogs-good.txt
## using ImageNet data and some visual inspection. See the file 
## nothotdog-find-data.R if you want to see how it was done.

## Retrieve API keys from keys.txt file, set API endpoint 
keys <- read.table("keys.txt", header=TRUE, stringsAsFactors = FALSE)

## Check to see if the default keys.txt file is still there
region <- keys["region",1]
if (region=="ERROR-EDIT-KEYS.txt-FILE") 
 stop("Edit the file keys.txt to provide valid keys. See README.md for details.")

## retrieve custom vision key
cvision_api_key <- keys["custom",1]
cvision_api_endpoint <- "https://southcentralus.api.cognitive.microsoft.com/customvision/v1.1/Training"

## Get the list of available training domains
domainsURL <- paste0(cvision_api_endpoint, "/domains")

APIresponse = GET(url = domainsURL,
                   content_type_json(),
                   add_headers(.headers= c('Training-key' = cvision_api_key)),
                   body="",
                   encode="json")

domains <- content(APIresponse)
domains.Food <- domains[[2]]$Id

## Create a project
createURL <- paste0(cvision_api_endpoint, "/projects?",
                    "name=nothotdogapp&",
                    'description=NotHotdog&',
                    'domainId=',domains.Food)

APIresponse = POST(url = createURL,
                   content_type_json(),
                   add_headers(.headers= c('Training-key' = cvision_api_key)),
                   body="",
                   encode="json")

cvision_id <- content(APIresponse)$Id

## Next, create tags we will use to label the images
## We will use "hotdog" for hot dog images and "nothotdog" for similar looking foods
## We will save the tag ids returned by the API for use later

## function to create one tag, and return its id
createTag <- function(id, tagname) {
 eURL <- paste0(cvision_api_endpoint, "/projects/", id, "/tags?",
                "name=",tagname)
 
 APIresponse = POST(url = eURL,
                    content_type_json(),
                    add_headers(.headers= c('Training-key' = cvision_api_key)),
                    body="",
                    encode="json")

 content(APIresponse)$Id 
}

hotdog_tag <- createTag(cvision_id, "hotdog")
nothotdog_tag <- createTag(cvision_id, "nothotdog")
tags <- c(hotdog = hotdog_tag, nothotdog=nothotdog_tag)

## Upload images to Custom Vision. We will cycle through lists of URLs
## provided in the txt files

uploadURLs <- function(id, tagname, urls) {
 ## id: Project ID
 ## tagname: one tag (applued to all URLs), as a tag ID
 ## urls: vector of image URLs

 eURL <- paste0(cvision_api_endpoint, "/projects/", id, "/images/url")
 success <- logical(0)
  
 ## The API accepts 64 URLs at a time, max, so:
 while(length(urls) > 0) {

  N <- min(length(urls), 64) 
  urls.body <- toJSON(list(TagIds=tagname, Urls=urls[1:N]))

  APIresponse = POST(url = eURL,
                    content_type_json(),
                    add_headers(.headers= c('Training-key' = cvision_api_key)),
                    body=urls.body,
                    encode="json")
 
  success <- c(success,content(APIresponse)$IsBatchSuccessful)
  urls <- urls[-(1:N)]
 }
 all(success)
}

uploadURLs(cvision_id, tags["hotdog"], hotdogs)
uploadURLs(cvision_id, tags["nothotdog"], nothotdogs)

## Get status of projects
projURL <- paste0(cvision_api_endpoint, "/projects/")

APIresponse = GET(url = projURL,
                   content_type_json(),
                   add_headers(.headers= c('Training-key' = cvision_api_key)),
                   body="",
                   encode="json")

projStatus <- content(APIresponse)

print(projStatus[[1]]$Id)
print(cvision_id) # should be the same

## Train project
trainURL <- paste0(cvision_api_endpoint, "/projects/",
                   cvision_id,
                   "/train")

APIresponse = POST(url = trainURL,
                   content_type_json(),
                   add_headers(.headers= c('Training-key' = cvision_api_key)),
                   body="",
                   encode="json")

train.id <- content(APIresponse)$Id

## Function to check status of a trained model (iteration)

iterStatus <- function(id) {
 iterURL <- paste0(cvision_api_endpoint, "/projects/",
                    cvision_id,
                    "/iterations/",
                    id)
 
 APIresponse = GET(url = iterURL,
                    content_type_json(),
                    add_headers(.headers= c('Training-key' = cvision_api_key)),
                    body="",
                    encode="json")
 
 content(APIresponse)$Status
}

## Keep checking this until the status is "Completed"
iterStatus(train.id)

## Next, let's create some predictions from our model
## For the next part, you will need to retrieve your prediction key
## from the customvision.ai service, as follows:

## 1. Visit https://customvision.ai
## 2. Click "Sign In"
## 3. Wait for projects to load, and then click your "qconhotdog" project
## 4. Click on Performance. Here you can check the precision and recall of your trained model.
## 5. Click on Prediction URL, and look at the "If you have an image URL" section
## 6. Check that the URL in the gray box matches cvision_api_endpoint_pred, below
## 7. Copy the key listed by "Set Prediction-Key Header to:" to cvision_pred_key below

cvision_api_endpoint_pred <- "https://southcentralus.api.cognitive.microsoft.com/customvision/v1.1/Prediction"
cvision_pred_key <- keys["cvpred",1]

## Function to generate predictions

hotdog_predict <- function(imageURL, threshold = 0.5) {
 predURL <- paste0(cvision_api_endpoint_pred, "/", cvision_id,"/url?",
                   "iterationId=",train.id,
                   "&application=R"
                   )

 body.pred <- toJSON(list(Url=imageURL[1]), auto_unbox = TRUE)

 APIresponse = POST(url = predURL,
                    content_type_json(),
                    add_headers(.headers= c('Prediction-key' = cvision_pred_key)),
                    body=body.pred,
                    encode="json")
 
 out <- content(APIresponse)
 
 if(!is.null(out$Code)) msg <- paste0("Can't analyze: ", out$Message) else
 {  
  predmat <- matrix(unlist(out$Predictions), nrow=3)
  preds <- as.numeric(predmat[3,])
  names(preds) <- predmat[2,]
  
  ## uncomment this to see the class predictions
  ## print(preds)
  
  if(preds["hotdog"]>threshold) msg <- "Hotdog" else
   if(preds["nothotdog"]>threshold) msg <- "Not Hotdog (but it looks delicious!)" else
    msg <- "Not Hotdog"
  }

  names(msg) <- imageURL[1]
  msg
}

hotdog_predict(hotdogs[1])
hotdog_predict(nothotdogs[1])

## here are some images to try, from a Google Image Search for "hotdog
example.hotdogs <- c(
 "http://www.wienerschnitzel.com/wp-content/uploads/2014/10/hotdog_mustard-main.jpg",
 "https://qz.com/wp-content/uploads/2017/07/hotdogs2__2__720.jpg?quality=80&strip=all",
 "http://www.americangarden.us/wp-content/uploads/2016/10/Recipe_Hot-dog-sandwich.jpg",
 "http://www.hot-dog.org/sites/default/files/pictures/hot-dogs-on-the-grill-sm.jpg",
 "https://www.dairyqueen.com/Global/Food/Hot-Dogs_8-to-1_470x500.jpg?width=&height=810"
)

## and a few Not Hotdog images to try
example.nothotdogs <- c(
 "https://upload.wikimedia.org/wikipedia/commons/thumb/4/46/Burrito_with_rice.jpg/1200px-Burrito_with_rice.jpg", #burrito
 "https://www.biggerbolderbaking.com/wp-content/uploads/2015/12/IMG_8761.jpg", # croissant
 "https://bigoven-res.cloudinary.com/image/upload/t_recipe-480/sausage-rolls.jpg", #sausage roll
 "https://www.recipetineats.com/wp-content/uploads/2017/09/Spring-Rolls-6.jpg", #spring rolls
 "https://images-gmi-pmc.edge-generalmills.com/b8488ce5-b076-420d-b0d0-e83039cae278.jpg" # jelly roll
)


hotdog_predict(example.hotdogs[1])
hotdog_predict(example.nothotdogs[1])

## Here's an example where the classification is wrong, at the 50% threshold
hotdog_predict(example.nothotdogs[4])

## We can be more conservative, at the expense of misclassifying some actual hotdogs
hotdog_predict(example.nothotdogs[4], threshold = 0.70)
hotdog_predict(example.hotdogs[3], threshold = 0.7)



