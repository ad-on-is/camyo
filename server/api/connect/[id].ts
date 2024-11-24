import { Device, sequelize } from "~/server/utils/db";

export default defineEventHandler(async (event) => {
  const existing = await Device.findOne({
    where: { uuid: event.context.params!.id },
  });
  if (existing) {
    let res = "";
    if (existing.ports.length == 0) {
      return res;
    }
    existing.ports.forEach((port) => {
      res += `${port.from}:${port.to}\n`;
    });
    existing.connectedAt = new Date();
    await existing.save();
    return res;
  }

  const device = await Device.create({
    uuid: event.context.params!.id,
    name: event.context.params!.id,
    connectedAt: new Date(),
    ports: [],
  });

  return "OK";
});
