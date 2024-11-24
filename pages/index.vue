<template>
  <div>
    <h3>Devices</h3>
    <table class="striped">
      <thead>
        <tr>
          <td width="50%">Device</td>
          <td width="50%">Ports</td>
        </tr>
      </thead>
      <tbody>
        <tr v-for="device in data" :key="device.uuid">
          <td>
            <NuxtLink :to="`/device/${device.id}`">{{
              device.name || "Undefined"
            }}</NuxtLink
            ><br /><small class="yellow">{{ device.uuid }}</small
            ><small>
              - Last connected:
              {{
                device.connectedAt === null
                  ? "Not yet"
                  : new Date(device.connectedAt).toLocaleString("en-GB")
              }}</small
            >
          </td>
          <td>
            <small v-if="device.ports.length === 0"
              ><NuxtLink :to="`/device/${device.id}`"
                >Please configure the device ports to expose.</NuxtLink
              ></small
            >
            <small
              v-else
              class="badge"
              :class="[port.active ? 'green' : 'lightGrey']"
              v-for="port in device.ports"
              :key="port.from"
            >
              {{ port.from }} -> {{ port.to }}<br />
            </small>
          </td>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<script setup lang="ts">
import type { Device } from "~/server/utils/db";

const { data } = useFetch<Device[]>("/api/devices");
let inter: Timer | null = null;
onMounted(() => {
  inter = setInterval(() => {
    data.value = useFetch<Device[]>("/api/devices").data.value;
  }, 1000);
});

onUnmounted(() => {
  if (inter !== null) clearInterval(inter);
});
</script>
