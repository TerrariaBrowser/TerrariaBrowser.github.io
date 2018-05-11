<template>
  <div class="resultWrapper">
    <div class="result">
      <h3>{{hit.name}}</h3>
      <p>ID: {{hit.itemid}}</p>
      <p><img :src="imageSrc" /></p>
    </div>
  </div>
</template>

<script>
export default {
  props: ['hit'],
  computed: {
    imageSrc() {
      return `/static/images/items/Item_${this.hit.itemid}.png`;
    }
  },

  filters: {
    formatLongNumber(number) {
      const decimalPlaces = 1;
      const base = Math.floor(Math.log(Math.abs(number)) / Math.log(1000));
      const suffix = 'kmbt'[base - 1];
      return suffix ? (number / (1000 ** base)).toFixed(decimalPlaces) + suffix : number;
    },
  },
};
</script>

<style lang="scss">
@import './Result.scss'
</style>
