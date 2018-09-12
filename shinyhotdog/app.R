library(shiny)

# Define UI for app that draws a histogram ----
ui <- fluidPage(
 
 # App title ----
 titlePanel("Not Hotdog"),
 
 # Sidebar layout with input and output definitions ----
 sidebarLayout(
  
  # Sidebar panel for inputs ----
  sidebarPanel(
   
   # Input: Image URL
   textInput("url", h3("Image URL"), value = "http://www.wienerschnitzel.com/wp-content/uploads/2014/10/hotdog_mustard-main.jpg
"),
   
   # Input: Detection threshold
   sliderInput(inputId = "threshold",
               label = "Identification threshold (%)",
               min = 0,
               max = 100,
               value = 50),
   
   h2("Some examples to try"),
   
   h3("Hotdogs"),
   
   a(href="https://www.dairyqueen.com/Global/Food/Hot-Dogs_8-to-1_470x500.jpg","Plain hotdog"), br(),
   a(href="http://www.wienerschnitzel.com/wp-content/uploads/2014/10/hotdog_mustard-main.jpg","Hotdog"), br(),
   a(href="https://qz.com/wp-content/uploads/2017/07/hotdogs2__2__720.jpg?quality=80&strip=all","Many hotdogs"), br(),
   a(href="http://www.americangarden.us/wp-content/uploads/2016/10/Recipe_Hot-dog-sandwich.jpg","Hotdog sandwich"), br(),
   a(href="http://www.hot-dog.org/sites/default/files/pictures/hot-dogs-on-the-grill-sm.jpg","Grilled hotdogs"), br(),
   
   h3("Not Hotdogs"),
   
   a(href="http://revolution-computing.typepad.com/.a/6a010534b1db25970b01774451bcc0970d-800wi","Naughty dog"), br(),
   a(href="https://images-gmi-pmc.edge-generalmills.com/b8488ce5-b076-420d-b0d0-e83039cae278.jpg", "Jam roll"), br(),
   a(href="https://upload.wikimedia.org/wikipedia/commons/thumb/4/46/Burrito_with_rice.jpg/1200px-Burrito_with_rice.jpg", "burrito"), br(),
   a(href="https://bigoven-res.cloudinary.com/image/upload/t_recipe-480/sausage-rolls.jpg", "Sausage roll"), br(),
   a(href="https://www.recipetineats.com/wp-content/uploads/2017/09/Spring-Rolls-6.jpg", "Spring roll"), br(),
   a(href="https://www.biggerbolderbaking.com/wp-content/uploads/2015/12/IMG_8761.jpg", "Croissant"), br()
   
   
   
  ),
 
  
  # Main panel for displaying outputs ----
  mainPanel(
   
   h1("Hotdog prediction"),
   
   # Output: Histogram ----
   textOutput("prediction"), p(),

   htmlOutput("imageDisplay")
   
   
  )
 )
)

library(httr)
library(jsonlite)
hotdog_preds <- function(imageURL, threshold = 0.5) {
 predURL <- "https://southcentralus.api.cognitive.microsoft.com/customvision/v2.0/Prediction/31dd2331-9ca0-4428-8660-9662b00de315/url?iterationId=977afda7-acb1-4824-b431-980470f92867"
 cvision_pred_key <- "6159b08b44a6453cb31ffca076e546da"
 
 body.pred <- toJSON(list(Url=imageURL[1]), auto_unbox = TRUE)
 
 APIresponse = POST(url = predURL,
                    content_type_json(),
                    add_headers(.headers= c('Prediction-key' = cvision_pred_key)),
                    body=body.pred,
                    encode="json")
 
 out <- content(APIresponse)

 msg <- NULL
 if(!is.null(out$code)) {
  msg <- paste0("Can't analyze: ", out$message)
  preds <- c(hotdog=0, nothotdog=0)
 } else {  
  predmat <- matrix(unlist(out$predictions), nrow=3)
  preds <- as.numeric(predmat[1,])
  names(preds) <- predmat[3,]
  
 }
 
 list(msg=msg,
      url=imageURL[1],
      preds=c(preds["hotdog"], preds["nothotdog"])
      )
}


# Define server logic required to draw a histogram ----
server <- function(input, output) {

 hotPred <- reactive({
  hotdog_preds(input$url)
 })
 
 output$imageDisplay <- renderText({
  paste0('<img src="', input$url, '",width=400px>')
 })

 output$prediction <- renderText({
  preds <- hotPred()$preds*100
  print(preds)
  msg <- hotPred()$msg
  if(is.null(hotPred()$msg)) {
   msg <- paste0("Not Hotdog (conf: ", floor(max(preds)),"%)")
   if(preds["nothotdog"]>input$threshold) msg <- "Not Hotdog (other food)"
   if(preds["hotdog"]>input$threshold && preds["hotdog"]>preds["nothotdog"]) msg <- "Hotdog"
  }
  msg 
 }) 

}


shinyApp(ui = ui, server = server)
