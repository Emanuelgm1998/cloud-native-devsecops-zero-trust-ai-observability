import express from "express";
import helmet from "helmet";
import morgan from "morgan";

const app = express();
const PORT = process.env.PORT || 3000;

app.use(helmet({ contentSecurityPolicy: false }));
app.use(morgan("tiny"));
app.use(express.json());

app.get("/", (_req, res) => {
  res.json({ service: "api", status: "ok", message: "DevSecOps API up", health: "/health" });
});

app.get("/health", (_req, res) => {
  res.status(200).json({ status: "healthy" });
});

app.use((req, res) => {
  res.status(404).json({ error: "Not found", path: req.path });
});

app.listen(PORT, () => console.log(`API listening on http://0.0.0.0:${PORT}`));
