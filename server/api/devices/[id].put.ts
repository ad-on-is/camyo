import { Device } from "~/server/utils/db";

export default defineEventHandler(async (event) => {
  // update device
  const data = await readBody<Device>(event);
  const devices = await Device.findAll();
  const usedPorts = devices
    .map((device) => device.ports.map((port) => port.to))
    .flat();
  console.log(usedPorts);

  data.ports = data.ports.map((port) => {
    if (port.to === 0) {
      port.to = getRandomPort();
      while (usedPorts.includes(port.to)) {
        port.to = getRandomPort();
      }
    }
    return port;
  });

  await Device.update(
    { name: data.name, ports: data.ports },
    { where: { id: event.context.params!.id } }
  );

  return data;
});

function getRandomPort() {
  let min = 49152;
  let max = 65535;
  min = Math.ceil(min);
  max = Math.floor(max);
  return Math.floor(Math.random() * (max - min + 1)) + min;
}
