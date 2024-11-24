import { $ } from "bun";
import {
  Sequelize,
  DataTypes,
  Model,
  InferAttributes,
  InferCreationAttributes,
  CreationOptional,
  NonAttribute,
} from "sequelize";
const sequelize = new Sequelize({
  dialect: "sqlite",
  logging: (...msg) =>
    console.log(msg[0].replace("Executing (default): ", "[DB]: ")),
  storage: process.env.DB_FILE || "db.sqlite",
});

class Device extends Model<
  InferAttributes<Device>,
  InferCreationAttributes<Device>
> {
  declare id: CreationOptional<number>;
  declare connectedAt: CreationOptional<Date>;
  declare createdAt: CreationOptional<Date>;
  declare updatedAt: CreationOptional<Date>;
  declare uuid: string;
  declare name: string;
  declare ports: CreationOptional<
    { from: number; to: number; active: boolean | null }[]
  >;
}

async function initDB() {
  await Device.init(
    {
      id: {
        type: DataTypes.INTEGER.UNSIGNED,
        autoIncrement: true,
        primaryKey: true,
      },
      name: {
        type: new DataTypes.STRING(128),
        allowNull: false,
      },
      uuid: {
        type: new DataTypes.STRING(128),
        allowNull: false,
      },
      ports: {
        type: new DataTypes.JSON(),
        allowNull: false,
      },
      createdAt: DataTypes.DATE,
      connectedAt: DataTypes.DATE,
      updatedAt: DataTypes.DATE,
    },
    {
      tableName: "Devices",
      sequelize, // passing the `sequelize` instance is required
    }
  );
  await sequelize.sync();
}

async function netstat(port: number): Promise<boolean> {
  try {
    const ss = await $`ss -tln | grep :${port}`.text();
    return ss !== "";
  } catch (e) {}
  return false;
}

async function getPortStatus(device: Device | null): Promise<Device | null> {
  if (!device) {
    return device;
  }
  for (let j = 0; j < device.ports.length; j++) {
    const port = device.ports[j];
    port.active = await netstat(port.to);
    device.ports[j] = port;
  }
  return device;
}

export { sequelize, Device, getPortStatus, initDB };
