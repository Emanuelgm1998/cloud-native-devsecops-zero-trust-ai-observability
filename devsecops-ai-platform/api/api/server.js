const express = require('express');
const bodyParser = require('body-parser');
const axios = require('axios');
const swaggerUi = require('swagger-ui-express');
const swaggerDocument = require('./docs/swagger.json');

const app = express();
app.use(bodyParser.json());
app.use('/docs', swaggerUi.serve, swaggerUi.setup(swaggerDocument));

app.post('/analyze', async (req, res) => {
  const inputData = req.body;
  if (!Array.isArray(inputData) || inputData.length === 0) {
    return res.status(400).json({ error: 'El cuerpo debe ser un array de métricas.' });
  }
  try {
    const response = await axios.post('http://ai:5000/detect', inputData);
    res.status(200).json(response.data);
  } catch (error) {
    console.error('❌ Error al conectar con el microservicio AI:', error.message);
    res.status(500).json({ error: 'Error al procesar los datos con el modelo AI.' });
  }
});

app.listen(3000, () => {
  console.log('🚀 API corriendo en http://localhost:3000');
});
