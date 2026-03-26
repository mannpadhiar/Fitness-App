import app from "./app.js";

const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log(`🚀 Server running on ${process.env.BASE_URL}`);
  console.log(`📋 Health check: ${process.env.BASE_URL}/api/health`);
});
