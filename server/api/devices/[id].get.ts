import { Device, getPortStatus } from "~/server/utils/db";

export default defineEventHandler(async (event) => {
  const device = await Device.findOne({
    where: { id: event.context.params!.id },
  });

  return await getPortStatus(device);
});
