const dotenv = require("dotenv");

let ENV_FILE_NAME = "";
switch (process.env.NODE_ENV) {
  case "production":
    ENV_FILE_NAME = ".env.production";
    break;
  case "staging":
    ENV_FILE_NAME = ".env.staging";
    break;
  case "test":
    ENV_FILE_NAME = ".env.test";
    break;
  default:
    ENV_FILE_NAME = ".env";
}

dotenv.config({ path: ENV_FILE_NAME });

module.exports = {
  projectConfig: {
    redis_url: process.env.REDIS_URL || "redis://localhost:6379",
    database_url: process.env.DATABASE_URL || "postgres://postgres:password@localhost:5432/medusa-db",
    database_type: "postgres",
    store_cors: process.env.STORE_CORS || "http://localhost:8000",
    admin_cors: process.env.ADMIN_CORS || "http://localhost:7000",
  },
  plugins: [],
};
