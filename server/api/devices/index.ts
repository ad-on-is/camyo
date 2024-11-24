import { Device, getPortStatus } from "~/server/utils/db";

export default defineEventHandler(async (event) => {
  const devices = await Device.findAll();
  return await Promise.all(
    devices.map(async (device) => await getPortStatus(device))
  );
});
