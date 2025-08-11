import express from "express";
import cors from "cors";
import helmet from "helmet";
import axios from "axios";

const app = express();
app.use(express.json());
app.use(cors());
app.use(helmet({
  crossOriginOpenerPolicy: { policy: "same-origin" },
  crossOriginResourcePolicy: { policy: "same-origin" },
  referrerPolicy: { policy: "no-referrer" }
}));

const PORT = process.env.PORT || 3000;
const AI_URL = process.env.AI_URL || "http://ai:5000";

app.get("/", (_req, res) => res.send("✅ API Node corriendo"));
app.get("/status", (_req, res) => res.json({ status: "ok", service: "api", ts: Date.now() }));

// Proxy simple hacia AI /detect
app.post("/detect", async (req, res) => {
  try {
    const { data } = await axios.post(`${AI_URL}/detect`, req.body, { timeout: 5000 });
    res.json({ ok: true, source: "api", result: data });
  } catch (e) {
    res.status(502).json({ ok: false, error: e?.message || "AI upstream error" });
  }
});

app.listen(PORT, () => console.log(`API escuchando en :${PORT}`));
