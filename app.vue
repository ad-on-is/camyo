<template>
  <div class="row">
    <div class="col-9 m-auto">
      <h1 class="is-center">Camy-O</h1>
      <h2 class="is-center lightGrey">Bring your remote devices back home.</h2>
      <div class="is-center"><NuxtLink to="/">Devices</NuxtLink></div>
      <NuxtPage />
    </div>
  </div>
</template>

<script setup lang="ts">
useHead({
  bodyAttrs: {
    class: "dark",
  },
});
</script>
