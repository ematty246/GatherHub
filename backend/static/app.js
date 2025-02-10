const express = require('express');
const fileUpload = require('express-fileupload');
const { GoogleGenerativeAI, HarmBlockThreshold, HarmCategory } = require('@google/generative-ai');
const MarkdownIt = require('markdown-it');
const app = express();
const PORT = 3000;
const ipAddress = '192.168.208.86';
const cors = require('cors');
app.use(cors());

// 🔥 Your Gemini API Key
const API_KEY = 'GEMINI-API-KEY';

// Middleware for handling file uploads
app.use(fileUpload());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.post('/generate', async (req, res) => {
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
        `Analyze this image and classify it as Flooded or Not Flooded based on the following:
  
        Flooded: Water completely submerges the area, such as roads, streets, or structures, indicating a true flood scenario where significant portions are covered by water.
  
        Not Flooded: If the image shows water but does not completely submerge the area, and significant portions of roads, streets, or structures are still visible, classify it as Not Flooded.
  
        Calculate the confidence score. If the confidence score is above 50%, classify the image as Flooded. If the confidence score is below 50%, classify it as Not Flooded as Classification field present in the response, Classification: Flooded or Not Flooded`
      ;
  
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
