# Not Hotdog: An application to detect images of hotdogs

_An example of the Microsoft Custom Vision API, inspired by 
[Silicon Valley](https://www.youtube.com/watch?v=ACmydtFDTGs)_

David M Smith ([\@revodavid](https://twitter.com/revodavid)), Developer Advocate at Microsoft

## Companion Resources

Blog Posts: [Not Hotdog with Custom Vision](http://blog.revolutionanalytics.com/2018/04/not-hotdog.html) (Revolutions blog, April 2018); 
[Not Hotdog Shiny App](https://blog.revolutionanalytics.com/2018/09/not-hotdog-a-shiny-app-using-the-custom-vision-api.html) (Revolutions blog, September 2018).

[Video: QCon.ai Conference](http://blog.revolutionanalytics.com/2018/07/r-for-ai-video.html) (San Francisco, July 2018) 

[Slides: EARL Conference](https://1drv.ms/p/s!AmZ4s9FA7xRJjnR1-XUnlcWJ85JK) (London, September 2018).

## Requirements

To run this script, you will need:

1. [R](http://www.r-project.org). Any version of R later than R 3.4.0 should work. 

1. A [Microsoft account](https://account.microsoft.com/account?WT.mc_id=opensource-0000-davidsmi). You can use an existing Outlook 365
or Xbox Live account, or create a new one.

1. A Microsoft Azure subscription. If you don't already have an Azure subscription, you can visit
https://cda.ms/kT and also get $200 in credits to use with paid services. You'll need to provide
a credit or debit card, but everything we'll be doing is free to use. If you're a student, you can 
also register at https://cda.ms/kY without a credit card for a $100 credit.

You'll also need a few other things specific to this application. Follow the instructions below to 
set up everything you need.

## Log in to the Azure Portal

1. Visit https://portal.azure.com/?WT.mc_id=opensource-0000-davidsmi 
2. Sign in with your Microsoft Account. If you don't have a Microsoft account, use the 
   links above to create one for free.

## Create an Azure Resource Group

In Azure, a Resource Group is a collection of services you have created. It groups services
together, and makes it easy to bulk-delete things later on. We'll create one for this lab.

1. Visit https://portal.azure.com/?WT.mc_id=opensource-0000-davidsmi (and sign in if needed)
2. Click "Resource Groups" in the left column
3. Click "+ Add"
    * Resource Group Name: nothotdog
    * Subscription: _there should be just one option_
    * Resource Group Location: South Central US
4. Click "Create"
   
A notification will appear in the top right. Click the button "Pin to Dashboard" to pin this resource group to your home page in the Azure portal, as you'll be referring to it frequently.

## Create authorization keys for Custom Vision

1. Visit https://portal.azure.com/?WT.mc_id=opensource-0000-davidsmi (and sign in if needed)
2. Click "+ Create a Resource" (top-left corner)
3. With the "Search the Marketplace" box, search for "Custom Vision Service"
4. Select "Custom Vision Service (preview)" and click "Create"
    * Name: nothotdog-customvision
    * Subscription: _there should be just one option_
    * Location: South Central US
    * Prediction Pricing Tier: F0 (free, 2 transactions per second)
    * Training pricing Tier: F0 (2 projects)
    * Resource Group: Use existing "nothotdog" group
5. Click "Create"

## Modify the keys.txt file

Download the file `keys.txt` and provide the keys listed from the Azure Portal. For the first line
of the file, `region`, leave as `eastus`. For the remaining keys, visit your `qcon` resource
group in the [Azure Portal](https://portal.azure.com/?WT.mc_id=opensource-0000-davidsmi) and then:

1. Open the `keys.txt` file and change the `region` entry to `southcentralus`
1. Visit https://portal.azure.com/?WT.mc_id=opensource-0000-davidsmi (and sign in if needed)
1. Look at the resources in "Resources / NOTHOTDOG" on your dashboard. (If you don't see it, click on Resource Groups in the left menu)
1. Click on the API resource for Custom Vision `nothotdog-customvision`
1. In the menu, click on "Keys"
1. Click the "copy to clipboard" next to KEY 1. (You can ignore KEY 2).
1. Paste the key into the `vision` entry in `keys.txt`
1. Return to your `nothotdog` resource group
1. Click on the API resource `nothotdogcustomvis_Prediction`
1. In the menu, click on "Keys"
1. Click the "copy to clipboard" next to KEY 1. (You can ignore KEY 2).
1. Paste the key into the `cvpred` entry in `keys.txt`

Your final `keys.txt` file will look like this, but with different (working) keys:

```
       key
region southcentralus
custom 1632b49e2930430694a9bbd3ab0c0cc2
cvpred 37eb1f0e5fd34253939350197ae3d933
```

## Get started!

Open the R script `nothotdog.R` to walk through the process of creating a custom vision application.

## Getting help

If you get stuck or just have other questions, please file an issue to this repo and I'll respond.
You can also contact me here:

David Smith `davidsmi@microsoft.com`
