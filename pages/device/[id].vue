<template>
  <!-- <pre>{{ data }}</pre> -->
  <h1 class="orange">{{ data?.uuid }}</h1>
  <form @submit="submit">
    <fieldset>
      <legend>Device Info</legend>

      <div>
        <label>Name</label>
        <input type="text" v-model="data!.name" />
      </div>
    </fieldset>
    <fieldset>
      <legend>Ports</legend>
      <p>
        Add the ports of your device that you want to have exposed. Here, you'd
        usually add HTTP (80), RTSP (543), etc. ports
      </p>
      <div v-for="(port, i) in data!.ports" :key="i">
        <div class="input-group is-center">
          <small v-if="port.to > 0" :class="port.active ? 'green' : 'yellow'">
            {{ port.to }} ->
          </small>
          <small v-else></small>
          <input type="number" v-model="port.from" />
          <small class="red pointer" @click="data!.ports.splice(i, 1)"
            >Delete</small
          >
          <small class="porttemplates pointer" v-if="port.from === 0">
            <span class="badge" @click="port.from = 80">HTTP</span>
            <span class="badge" @click="port.from = 443">HTTPS</span>
            <span class="badge" @click="port.from = 22">SSH</span>
            <span class="badge" @click="port.from = 554">RTSP</span>
          </small>
        </div>
      </div>
      <input
        type="button"
        class="button secondary"
        value="Add"
        @click="data!.ports.push({ from: 0, to: 0, active: false })"
      />
    </fieldset>
    <button class="button primary">Save</button>
  </form>
</template>

<script setup lang="ts">
import type { Device } from "~/server/utils/db";

const { id } = useRoute().params;

const { data } = await useFetch<Device>(`/api/devices/${id}`);

const submit = async (e: Event) => {
  e.preventDefault();
  const modified = await useFetch(`/api/devices/${id}`, {
    method: "PUT",
    body: data.value,
  });
  console.log(modified.data.value);
  data.value = modified.data.value as Device;
  // navigateTo(`/`);
};
</script>
