const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;

// Simulación de base de datos (puedes reemplazarlo por consulta real)
const asistencias = [
    { id: 1, nombre: 'Juan Pérez', fecha: '2025-05-09', hora: '08:00' },
    { id: 2, nombre: 'Ana Gómez', fecha: '2025-05-09', hora: '08:10' },
    { id: 3, nombre: 'Luis Díaz', fecha: '2025-05-08', hora: '07:55' },
];

// Ruta para consultar asistencias por fecha
app.get('/asistencias', (req, res) => {
    const fecha = req.query.fecha;
    if (!fecha) {
        return res.status(400).json({ error: 'Debe proporcionar una fecha en formato YYYY-MM-DD' });
    }

    const resultados = asistencias.filter(a => a.fecha === fecha);
    res.json(resultados);
});

// Iniciar servidor
app.listen(PORT, () => {
    console.log(`API de asistencias corriendo en puerto ${PORT}`);
});
