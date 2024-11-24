import { initDB } from "../utils/db";

export default defineNitroPlugin(async (nitroApp) => {
  await initDB();
});
