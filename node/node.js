const express = require('express');
const fileUpload = require('express-fileupload');
const { GoogleGenerativeAI, HarmBlockThreshold, HarmCategory } = require('@google/generative-ai');
const MarkdownIt = require('markdown-it');
const app = express();
const PORT = 3001;
const ipAddress = '192.168.208.86';
const cors = require('cors');
app.use(cors());

require('dotenv').config();
const API_KEY = process.env.API_KEY;


// Middleware for handling file uploads
app.use(fileUpload());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.post('/analyze', async (req, res) => {
    if (!req.files || !req.files.image) {
      return res.status(400).send('Image is required.');
    }
  
    try {
      const imageFile = req.files.image;
  
      console.log(`Received image: ${imageFile.name}, MIME type: ${imageFile.mimetype}, size: ${imageFile.size}`);

  
      // If the MIME type is 'application/octet-stream', assume it's a JPEG
      if (imageFile.mimetype === 'application/octet-stream') {
        console.log('Assuming the image is a JPEG.');
        imageFile.mimetype = 'image/jpeg'; // Force MIME type to image/jpeg
      }
  
      // Now check if the MIME type is 'image/jpeg'
      if (imageFile.mimetype !== 'image/jpeg') {
        console.log('Error: Received image is not a JPEG.');
        return res.status(400).send('Only JPEG images are allowed.');
      }
  
      // Convert the image to base64
      const imageBase64 = imageFile.data.toString('base64');
      console.log("Image converted to base64.");
  
      // Define the prompt (centralized in the backend)
      const prompt = 
      `Analyze the waste items detected in this image and classify each item as Recyclable or Non-Recyclable. Additionally, scan the room/building/area to check if water-related items (e.g., water bottles, water containers, etc.) are present or not.

Recyclable: Paper, plastic bottles, glass, metal cans, cardboard.
Non-Recyclable: Food waste, contaminated plastic, broken ceramics, hazardous materials.
Provide a confidence score for each detected item. If the score is above 50%, classify it as Recyclable; otherwise, classify it as Non-Recyclable. Also, identify if any water-related items are present in the room/building/area and provide a confidence score for that as well.

Response Format:

Item Name: The detected waste item.

Classification: Recyclable or Non-Recyclable.

Confidence Score: Numeric value indicating classification confidence.

Water-Related Item: Indicate whether water-related items (such as bottles, containers) are present or not.

Water-Item Confidence Score: Confidence score indicating the likelihood of water-related items being detected. And if the image contains more than one item then the response must be Item 1, Item 2 and so on.`;
  
      // Assemble the request contents
      const contents = [
        {
          role: 'user',
          parts: [
            { inline_data: { mime_type: 'image/jpeg', data: imageBase64 } },
            { text: prompt },
          ],
        },
      ];
  
      // Initialize the Gemini API
      const genAI = new GoogleGenerativeAI(API_KEY);
      const model = genAI.getGenerativeModel({
        model: 'gemini-1.5-flash', // or gemini-1.5-pro
        safetySettings: [
          {
            category: HarmCategory.HARM_CATEGORY_HARASSMENT,
            threshold: HarmBlockThreshold.BLOCK_ONLY_HIGH,
          },
        ],
      });
  
      // Generate content from the multimodal model
      const result = await model.generateContentStream({ contents });
  
      // Wait for the stream to finish processing and collect the response
      let markdownOutput = '';
      for await (let response of result.stream) {
        markdownOutput += response.text();
      }
  
      // Log the generated markdown output for debugging
      console.log("Generated markdownOutput: ", markdownOutput);
  
      // Return the generated markdown output
      res.status(200).send({ markdownOutput });
  
    } catch (error) {
      console.error("Error during image processing: ", error);
      res.status(500).send('An error occurred while generating content.');
    }
  });
  

app.listen(PORT, () => {
  console.log(`Server running on http://${ipAddress}:${PORT}`);
});